// =============================================================================
//  PrescriptionBridge — a doctor's prescription, into her own health record
// -----------------------------------------------------------------------------
//  THE GAP THIS CLOSES, and it is the one a user described as "where does that
//  go into the parent?".
//
//  There are two things called "prescription" in this app and they had never
//  met:
//
//    A. the CONSULT prescription — `prescriptions` (0032), written by the
//       doctor through write_prescription(), scoped to a booking, immutable,
//       read only inside My Bookings;
//
//    B. the HEALTH RECORD — `pp_prescriptions` / `pp_medications` (0022),
//       scoped to a child, entirely self-entered by the parent, and the place
//       every other part of the app looks for "what is she taking".
//
//  So Health -> Prescriptions said "No prescriptions saved yet" while a
//  doctor-written prescription sat in the database, and the medicines a
//  clinician had just prescribed reached no tracker and no reminder. The
//  mother's job was to read one screen and retype it into another.
//
// -----------------------------------------------------------------------------
//  WHY THIS COPIES RATHER THAN MERGES — and it is a clinical decision, not a
//  storage one.
//
//  The obvious design is to make Health read from both tables. It is wrong.
//  Those two records answer different questions and have different owners:
//
//    * The consult prescription is what a CLINICIAN said. It must stay exactly
//      as written, for as long as it exists, and the parent must not be able
//      to edit it — which is why 0032 grants no UPDATE to anybody.
//    * The health record is HERS. She annotates it, marks a course finished,
//      corrects a dose her doctor changed over the phone, attaches a photo of
//      the paper script.
//
//  A single mutable view of both would let an edit to the second silently
//  rewrite the first, or freeze the second because the first cannot change.
//  Truth hierarchy (truth_hierarchy.dart) puts a treating clinician above
//  everything we hold, so the doctor's row stays untouched and authoritative,
//  and what lands in her record is a labelled COPY that says where it came
//  from.
//
//  The copy is also DELIBERATE, never automatic. Filing something into
//  somebody's medical record is an action with her name on it; she taps it.
// -----------------------------------------------------------------------------
//  IDEMPOTENT BY CONSTRUCTION. Both rows are keyed off the consult
//  prescription's own id, so tapping twice — or tapping again on another
//  device after a sync — writes the same ids rather than a second copy. Same
//  reasoning as the app generating booking ids so a local row and its cloud
//  copy share one identity.
// =============================================================================

import '../screens/post_pregnancy/pp_health_data.dart' as health;
import '../screens/post_pregnancy/pp_experts_data.dart';
import 'prescription.dart';

class PrescriptionBridge {
  PrescriptionBridge._();

  /// The id the health-record copy of [rx] would have.
  static String recordId(Prescription rx) => 'presrx_${rx.id}';

  /// The id the health-record medication for item [i] of [rx] would have.
  static String medicationId(Prescription rx, int i) => 'medrx_${rx.id}_$i';

  /// Has this prescription already been filed into her records?
  static bool alreadySaved(Prescription rx) =>
      health.HealthStore.instance.prescriptions
          .any((p) => p.id == recordId(rx));

  /// Copy [rx] into the health record: one prescription row, plus one
  /// medication row per medicine so trackers and reminders can see them.
  ///
  /// Returns the number of medicines filed. Safe to call twice.
  static int saveToHealthRecord(Prescription rx, {String? fallbackTitle}) {
    final store = health.HealthStore.instance;

    // expertByIdOrNull, not expertById: the latter falls back to the FIRST
    // doctor in the catalogue for an unknown id, which on a medical record
    // would attribute a prescription to a real clinician who never wrote it.
    final expert = expertByIdOrNull(rx.expertId);
    final doctor = expert?.name ?? '';
    final when = _date(rx.createdUtc);

    if (!alreadySaved(rx)) {
      store.addPrescription(health.Prescription(
        id: recordId(rx),
        name: (fallbackTitle?.trim().isNotEmpty ?? false)
            ? fallbackTitle!.trim()
            : 'Consultation prescription',
        doctor: doctor,
        date: when,
        // The advice travels with it. It is the only free text a doctor can
        // leave anywhere in the product, so losing it in the copy would lose
        // it entirely from the record she actually reads.
        notes: _notes(rx),
      ));
    }

    var filed = 0;
    final existing = {for (final m in store.medications) m.id};
    for (var i = 0; i < rx.items.length; i++) {
      final it = rx.items[i];
      if (it.isEmpty) continue;
      final id = medicationId(rx, i);
      if (existing.contains(id)) continue;
      store.addMedication(health.Medication(
        id: id,
        name: it.medicine,
        // "Why is she on this?" — the consult it came from is the honest
        // answer, and the only one we hold.
        reason: (fallbackTitle?.trim().isNotEmpty ?? false)
            ? fallbackTitle!.trim()
            : 'Prescribed at a consultation',
        doctor: doctor,
        dosage: it.dosage,
        duration: it.duration,
        completed: false,
        date: when,
        // System A has no frequency field of its own — a doctor writes "1
        // tablet twice a day" into Dosage — so this stays empty rather than
        // guessing at a split. Noted as a real gap in the audit.
        frequency: '',
      ));
      filed++;
    }
    return filed;
  }

  static String _notes(Prescription rx) {
    final lines = <String>[
      for (final it in rx.items)
        if (!it.isEmpty)
          [
            it.medicine,
            if (it.dosage.isNotEmpty) it.dosage,
            if (it.duration.isNotEmpty) 'for ${it.duration}',
          ].join(' · '),
    ];
    final advice = rx.advice.trim();
    if (advice.isNotEmpty) lines.add(advice);
    return lines.join('\n');
  }

  static const _mo = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', //
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];

  static String _date(DateTime utc) {
    final d = utc.toLocal();
    return '${d.day} ${_mo[d.month - 1]} ${d.year}';
  }
}

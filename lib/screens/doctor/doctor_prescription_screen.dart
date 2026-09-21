// =============================================================================
//  DoctorPrescriptionScreen — the doctor writes a prescription
// -----------------------------------------------------------------------------
//  A form: add medicine rows (name · dosage · duration) and free-text advice,
//  then save. Goes through write_prescription() (the doctor never touches the
//  patient's id), and lands in the parent's app against this booking.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/prescription.dart';
import '../../doctor/doctor_session.dart';
import 'doctor_chrome.dart';

class DoctorPrescriptionScreen extends StatefulWidget {
  const DoctorPrescriptionScreen({
    super.key,
    required this.bookingId,
    required this.title,
    this.backLabel = 'Dashboard',
  });

  final String bookingId;
  final String title;

  /// Where "back" actually goes. Since the chrome's back is a plain arrow
  /// (2026-09-21) the label is no longer drawn; kept so callers need not
  /// change, and so the history below still reads.
  ///
  ///
  /// It was hardcoded to 'Dashboard', which is right from the home screen and
  /// wrong from Appointments - the only other door into this screen, and the
  /// one a doctor writing up a past consult comes through. A back arrow that
  /// names the wrong place is worse than an unlabelled one.
  final String backLabel;

  @override
  State<DoctorPrescriptionScreen> createState() =>
      _DoctorPrescriptionScreenState();
}

class _Row {
  final med = TextEditingController();
  final dose = TextEditingController();
  final dur = TextEditingController();
  void dispose() {
    med.dispose();
    dose.dispose();
    dur.dispose();
  }
}

class _DoctorPrescriptionScreenState extends State<DoctorPrescriptionScreen> {
  final List<_Row> _rows = [_Row()];
  final _advice = TextEditingController();
  bool _saving = false;

  /// True when this booking already had a prescription when the screen opened.
  ///
  /// It matters twice: the form is PREFILLED rather than blank, and the button
  /// says "Update" rather than "Send".
  bool _amending = false;

  @override
  void initState() {
    super.initState();
    _prefill();
  }

  /// THE DUPLICATE THIS PREVENTS.
  ///
  /// Appointments flips its label to "View prescription" once one exists, and
  /// then pushed this identical, EMPTY form. A doctor tapping "view" saw a
  /// blank page, reasonably concluded nothing had been written, typed it again
  /// and saved — which minted a second `rx_` id and inserted a SECOND ROW
  /// (0032 has no unique constraint on booking_id). The parent then saw
  /// whichever of the two came back first.
  ///
  /// Showing what is already there fixes the cause rather than the symptom.
  void _prefill() {
    final existing =
        PrescriptionStore.instance.forBooking(widget.bookingId);
    if (existing == null) return;
    _amending = true;
    _advice.text = existing.advice;
    if (existing.items.isNotEmpty) {
      _rows.clear();
      for (final it in existing.items) {
        final r = _Row();
        r.med.text = it.medicine;
        r.dose.text = it.dosage;
        r.dur.text = it.duration;
        _rows.add(r);
      }
    }
  }

  @override
  void dispose() {
    for (final r in _rows) {
      r.dispose();
    }
    _advice.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final items = [
      for (final r in _rows)
        if (r.med.text.trim().isNotEmpty)
          RxItem(
            medicine: r.med.text.trim(),
            dosage: r.dose.text.trim(),
            duration: r.dur.text.trim(),
          ),
    ];
    if (items.isEmpty && _advice.text.trim().isEmpty) {
      _snack('Add at least one medicine or a note.');
      return;
    }
    setState(() => _saving = true);
    final ok = await PrescriptionStore.instance.write(
      bookingId: widget.bookingId,
      items: items,
      advice: _advice.text.trim(),
      // So the parent's copy can name who prescribed it. The server sets the
      // authoritative value; this only keeps the local mirror honest.
      expertId: DoctorSession.instance.expertId ?? '',
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      _snack(_amending
          ? 'Prescription updated for the parent.'
          : 'Prescription sent to the parent.');
      Navigator.of(context).maybePop();
    } else {
      // Includes the case that used to report success: signed out, so nothing
      // was written at all. See PrescriptionStore.write.
      _snack('Could not save. Check you are signed in, then try again.');
    }
  }

  void _snack(String m) => dcToast(context, m);

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    // 2026-09-21: onto the doctor chrome. This was the doctor's most-used
    // screen after Appointments and the last one still in the parenting
    // palette — violet eyebrow, violet button, tinted fields.
    return DcScreen(
      title: _amending ? 'Update the prescription' : 'Write a prescription',
      subtitle: 'For ${widget.title}.',
      bottom: ObPrimary(
        p: p,
        label: _saving
            ? (_amending ? 'Updating…' : 'Sending…')
            : (_amending ? 'Update prescription' : 'Send prescription'),
        onTap: _saving ? null : _save,
      ),
      children: [
        const DcSectionHead('Medicines'),
        for (var i = 0; i < _rows.length; i++) ...[_medRow(i), const SizedBox(height: 10)],
        InkWell(
          onTap: () => setState(() => _rows.add(_Row())),
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(children: [
              Icon(Icons.add_rounded, size: 20, color: p.action),
              const SizedBox(width: 6),
              Text('Add another medicine', style: dcStrong(14, color: p.action)),
            ]),
          ),
        ),
        const SizedBox(height: 22),
        const DcSectionHead('Advice and notes'),
        _field(_advice, 'Rest, fluids, when to follow up…', lines: 4),
        const SizedBox(height: 12),
        const DcNotice('The parent sees this the moment you save. Anything clinical is yours; ParentVeda never changes a word.'),
      ],
    );
  }

  Widget _medRow(int i) {
    final r = _rows[i];
    final p = dcP;
    return DcCard(
      padding: const EdgeInsets.all(12),
      child: Column(children: [
        Row(children: [
          Expanded(child: _field(r.med, 'Medicine name')),
          if (_rows.length > 1) ...[
            const SizedBox(width: 6),
            IconButton(
              onPressed: () => setState(() {
                _rows.removeAt(i).dispose();
              }),
              icon: Icon(Icons.close_rounded, size: 20, color: p.ink3),
              tooltip: 'Remove',
            ),
          ],
        ]),
        const SizedBox(height: 8),
        Row(children: [
          Expanded(child: _field(r.dose, 'Dosage')),
          const SizedBox(width: 8),
          Expanded(child: _field(r.dur, 'Duration')),
        ]),
      ]),
    );
  }

  /// The chrome's field (DcInput) without the label: three sit on one row.
  Widget _field(TextEditingController c, String hint, {int lines = 1}) {
    final p = dcP;
    return TextField(
      controller: c,
      maxLines: lines,
      style: dcBody(15),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: dcBody(15, color: p.ink3),
        isDense: true,
        filled: true,
        fillColor: p.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.line, width: 1.2),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: p.ink1, width: 1.4),
        ),
      ),
    );
  }
}

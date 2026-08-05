// =============================================================================
//  DoctorPrescriptionScreen — the doctor writes a prescription
// -----------------------------------------------------------------------------
//  A form: add medicine rows (name · dosage · duration) and free-text advice,
//  then save. Goes through write_prescription() (the doctor never touches the
//  patient's id), and lands in the parent's app against this booking.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/prescription.dart';
import '../post_pregnancy/pp_common.dart';

class DoctorPrescriptionScreen extends StatefulWidget {
  const DoctorPrescriptionScreen({
    super.key,
    required this.bookingId,
    required this.title,
    this.backLabel = 'Dashboard',
  });

  final String bookingId;
  final String title;

  /// Where "back" actually goes.
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
    );
    if (!mounted) return;
    setState(() => _saving = false);
    if (ok) {
      _snack('Prescription sent to the parent.');
      Navigator.of(context).maybePop();
    } else {
      _snack('Could not save. Check your connection and try again.');
    }
  }

  void _snack(String m) => ScaffoldMessenger.of(context)
    ..clearSnackBars()
    ..showSnackBar(SnackBar(content: Text(m)));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: Column(children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              children: [
                ppBack(context, widget.backLabel),
                const SizedBox(height: 16),
                ppEyebrow('Prescription', color: ppPurple),
                const SizedBox(height: 8),
                Text('Write a prescription', style: ppFraunces(26, h: 1.1)),
                const SizedBox(height: 6),
                Text('For ${widget.title}.',
                    style: ppBody(13, color: ppSoft)),
                const SizedBox(height: 22),
                Text('MEDICINES',
                    style: ppBody(11, color: ppMuted, w: FontWeight.w800)
                        .copyWith(letterSpacing: 1.0)),
                const SizedBox(height: 10),
                for (var i = 0; i < _rows.length; i++) _medRow(i),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: () => setState(() => _rows.add(_Row())),
                  behavior: HitTestBehavior.opaque,
                  child: Row(children: [
                    const Icon(Icons.add_circle_outline_rounded,
                        size: 18, color: ppPurple),
                    const SizedBox(width: 7),
                    Text('Add another medicine',
                        style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                  ]),
                ),
                const SizedBox(height: 24),
                Text('ADVICE / NOTES',
                    style: ppBody(11, color: ppMuted, w: FontWeight.w800)
                        .copyWith(letterSpacing: 1.0)),
                const SizedBox(height: 10),
                _field(_advice, 'Rest, fluids, when to follow up…', lines: 4),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 20),
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border(top: BorderSide(color: ppHair)),
            ),
            child: GestureDetector(
              onTap: _saving ? null : _save,
              behavior: HitTestBehavior.opaque,
              child: Opacity(
                opacity: _saving ? 0.7 : 1,
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                      color: ppPurple, borderRadius: BorderRadius.circular(16)),
                  child: Text(_saving ? 'Sending…' : 'Send prescription',
                      style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                ),
              ),
            ),
          ),
        ]),
      ),
    );
  }

  Widget _medRow(int i) {
    final r = _rows[i];
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: ppHair),
      ),
      child: Column(children: [
        Row(children: [
          Expanded(child: _field(r.med, 'Medicine name')),
          if (_rows.length > 1) ...[
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => setState(() {
                _rows.removeAt(i).dispose();
              }),
              child: const Icon(Icons.close_rounded, size: 20, color: ppMuted),
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

  Widget _field(TextEditingController c, String hint, {int lines = 1}) =>
      TextField(
        controller: c,
        maxLines: lines,
        style: ppBody(13.5, color: ppInk),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: ppBody(13, color: ppMuted),
          isDense: true,
          filled: true,
          fillColor: ppPanel,
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 12, vertical: 11),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide.none,
          ),
        ),
      );
}

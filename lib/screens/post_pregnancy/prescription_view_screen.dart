// =============================================================================
//  PrescriptionViewScreen — the parent reads a doctor's prescription
// -----------------------------------------------------------------------------
//  A clean, read-only rendering of what the doctor wrote: the medicines with
//  their dosage and duration, and the advice. What the parent opens from a
//  consult in My Bookings.
//
//  READ-ONLY IS THE POINT, and it is why the "save to my records" button here
//  copies rather than moves. What a clinician wrote must stay exactly as
//  written — 0032 grants no UPDATE to anyone, deliberately — while the record
//  she keeps is hers to annotate. See PrescriptionBridge for the full
//  reasoning; this screen is the door to it.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/prescription.dart';
import '../../booking/prescription_bridge.dart';
import 'pp_common.dart';
import 'pp_experts_data.dart';

class PrescriptionViewScreen extends StatefulWidget {
  const PrescriptionViewScreen({
    super.key,
    required this.prescription,
    required this.title,
  });

  final Prescription prescription;
  final String title;

  @override
  State<PrescriptionViewScreen> createState() => _PrescriptionViewScreenState();
}

class _PrescriptionViewScreenState extends State<PrescriptionViewScreen> {
  late bool _saved = PrescriptionBridge.alreadySaved(widget.prescription);

  String get title => widget.title;

  void _saveToRecords() {
    final filed = PrescriptionBridge.saveToHealthRecord(
      widget.prescription,
      fallbackTitle: widget.title,
    );
    setState(() => _saved = true);
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(SnackBar(
        content: Text(filed == 0
            ? 'Saved to Health → Prescriptions.'
            : filed == 1
                ? 'Saved. 1 medicine added to your health records.'
                : 'Saved. $filed medicines added to your health records.'),
      ));
  }

  @override
  Widget build(BuildContext context) {
    final p = widget.prescription;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
          children: [
            ppBack(context, 'My Bookings'),
            const SizedBox(height: 16),
            ppEyebrow('Prescription', color: ppPurple),
            const SizedBox(height: 8),
            Text(title, style: ppFraunces(26, h: 1.12)),
            const SizedBox(height: 6),

            // WHO PRESCRIBED THIS.
            //
            // The model has carried `expertId` from the beginning and this
            // screen never rendered it — so a mother could open a prescription
            // and find no doctor's name on it anywhere. A prescription without
            // a prescriber is not a prescription; a pharmacist would hand it
            // back, and she has nobody to ask about a dose.
            //
            // expertByIdOrNull, never expertById: the fallback in the latter
            // returns a DIFFERENT REAL DOCTOR for an unknown id, and putting
            // the wrong clinician's name on a medical document is far worse
            // than putting none.
            _prescriber(p.expertId, p.createdUtc),
            const SizedBox(height: 22),

            if (p.items.isNotEmpty) ...[
              Text('MEDICINES',
                  style: ppBody(11, color: ppMuted, w: FontWeight.w800)
                      .copyWith(letterSpacing: 1.0)),
              const SizedBox(height: 10),
              for (final it in p.items) _item(it),
              const SizedBox(height: 12),
            ],

            if (p.advice.trim().isNotEmpty) ...[
              const SizedBox(height: 8),
              Text('ADVICE',
                  style: ppBody(11, color: ppMuted, w: FontWeight.w800)
                      .copyWith(letterSpacing: 1.0)),
              const SizedBox(height: 10),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: ppPurple.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: ppPurple.withValues(alpha: 0.15)),
                ),
                child: Text(p.advice, style: ppBody(14, color: ppInk, h: 1.6)),
              ),
            ],

            const SizedBox(height: 22),

            // THE BRIDGE. Without this the mother reads a prescription here and
            // then has to retype every line into Health -> Prescriptions and
            // her medicine reminders by hand, because the two have never been
            // connected. One tap, and it is filed where the rest of her medical
            // record lives and where her reminders can see it.
            _saveRow(),

            const SizedBox(height: 24),
            Text(
                'Always follow your doctor’s guidance. If anything worsens or '
                'you are unsure, contact them or a clinic.',
                textAlign: TextAlign.center,
                style: ppBody(11.5, color: ppMuted, h: 1.5)),
          ],
        ),
      ),
    );
  }

  Widget _saveRow() => GestureDetector(
        onTap: _saved ? null : _saveToRecords,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 16),
          decoration: BoxDecoration(
            color: _saved ? Colors.white : ppPurple,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: _saved ? ppHair : ppPurple),
          ),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(
                _saved
                    ? Icons.check_circle_outline_rounded
                    : Icons.save_alt_rounded,
                size: 18,
                color: _saved ? ppPurple : Colors.white),
            const SizedBox(width: 9),
            Flexible(
              child: Text(
                _saved
                    ? 'Saved to your health records'
                    : 'Save to my health records',
                style: ppBody(13.5,
                    color: _saved ? ppInk : Colors.white, w: FontWeight.w700),
              ),
            ),
          ]),
        ),
      );

  Widget _prescriber(String expertId, DateTime createdUtc) {
    final e = expertByIdOrNull(expertId);
    final when = _date(createdUtc);
    if (e == null) {
      // Unknown prescriber. Say when it was written and stop — the booking
      // title above usually still carries the doctor's name, and inventing one
      // here would be worse than the gap.
      return Text('Written $when', style: ppBody(12.5, color: ppSoft));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text('Prescribed by ${e.name}',
          style: ppBody(13, color: ppInk, w: FontWeight.w700)),
      if (e.credential.isNotEmpty)
        Padding(
          padding: const EdgeInsets.only(top: 2),
          child: Text(e.credential, style: ppBody(12, color: ppSoft)),
        ),
      Padding(
        padding: const EdgeInsets.only(top: 3),
        child: Text('Written $when', style: ppBody(12, color: ppSoft)),
      ),
    ]);
  }

  Widget _item(RxItem it) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(15, 13, 15, 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ppHair),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.medication_outlined, size: 18, color: ppPurple),
            const SizedBox(width: 9),
            Expanded(
              child: Text(it.medicine,
                  style: ppJakarta(15, color: ppTitleInk),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis),
            ),
          ]),
          if (it.dosage.isNotEmpty || it.duration.isNotEmpty) ...[
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.only(left: 27),
              child: Text(
                  [
                    if (it.dosage.isNotEmpty) it.dosage,
                    if (it.duration.isNotEmpty) 'for ${it.duration}',
                  ].join(' · '),
                  style: ppBody(12.5, color: ppSoft)),
            ),
          ],
        ]),
      );

  static const _mo = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
  ];
  String _date(DateTime utc) {
    final d = utc.toLocal();
    return '${d.day} ${_mo[d.month - 1]} ${d.year}';
  }
}

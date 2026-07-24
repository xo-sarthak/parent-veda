// =============================================================================
//  PrescriptionViewScreen — the parent reads a doctor's prescription
// -----------------------------------------------------------------------------
//  A clean, read-only rendering of what the doctor wrote: the medicines with
//  their dosage and duration, and the advice. What the parent opens from a
//  consult in My Bookings.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/prescription.dart';
import 'pp_common.dart';

class PrescriptionViewScreen extends StatelessWidget {
  const PrescriptionViewScreen({
    super.key,
    required this.prescription,
    required this.title,
  });

  final Prescription prescription;
  final String title;

  @override
  Widget build(BuildContext context) {
    final p = prescription;
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
            Text('Written ${_date(p.createdUtc)}',
                style: ppBody(12.5, color: ppSoft)),
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

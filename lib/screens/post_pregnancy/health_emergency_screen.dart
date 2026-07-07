// =============================================================================
//  HealthEmergencyScreen — the Emergency Card
// -----------------------------------------------------------------------------
//  The one screen you can hand to anyone in a crisis: name, photo, DOB, weight,
//  blood group, allergies, emergency contacts, paediatrician and current meds —
//  with a QR to the full profile and offline availability. Calm, clear, fast.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_health_data.dart';

class HealthEmergencyScreen extends StatelessWidget {
  const HealthEmergencyScreen({super.key});

  static const Color _red = Color(0xFFB0402E);

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final e = kEmergency;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Health')),
            const SizedBox(height: 18),
            _pad(Row(children: [
              const Icon(Icons.emergency_outlined, size: 18, color: _red),
              const SizedBox(width: 8),
              ppEyebrow('Emergency Card', color: _red, spacing: 1.2),
            ])),
            const SizedBox(height: 8),
            _pad(Text('In case of emergency', style: ppFraunces(28, h: 1.12))),
            const SizedBox(height: 6),
            _pad(Text('Everything a doctor or carer needs, fast — and available offline.', style: ppBody(14, h: 1.5))),

            const SizedBox(height: 20),
            _pad(Container(
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: _red.withValues(alpha: 0.3)), boxShadow: ppCardShadow),
              clipBehavior: Clip.antiAlias,
              child: Column(children: [
                // header band
                Container(
                  color: _red.withValues(alpha: 0.08),
                  padding: const EdgeInsets.all(18),
                  child: Row(children: [
                    Container(width: 60, height: 60, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)), clipBehavior: Clip.antiAlias, child: const PpStriped(height: 64)),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text(e.name, style: ppFraunces(24, h: 1.05)),
                        const SizedBox(height: 3),
                        Text('Born ${e.dob}  ·  ${e.weight}', style: ppBody(12.5, color: ppSoft)),
                      ]),
                    ),
                  ]),
                ),
                Padding(
                  padding: const EdgeInsets.all(18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: _big('Blood group', e.bloodGroup, _red)),
                      const SizedBox(width: 12),
                      Expanded(child: _big('Allergies', e.allergies, ppInk)),
                    ]),
                    const SizedBox(height: 16),
                    _row(Icons.medication_outlined, 'Current medications', e.medications),
                    const SizedBox(height: 12),
                    _row(Icons.medical_services_outlined, 'Paediatrician', e.pediatrician),
                    const SizedBox(height: 16),
                    Text('EMERGENCY CONTACTS', style: ppBody(9.5, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.6)),
                    const SizedBox(height: 10),
                    for (final c in e.contacts) _contact(c),
                    const SizedBox(height: 16),
                    // QR
                    Row(children: [
                      Container(
                        width: 76,
                        height: 76,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(color: ppBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppHair)),
                        child: const Icon(Icons.qr_code_2_rounded, size: 56, color: ppInk),
                      ),
                      const SizedBox(width: 14),
                      Expanded(child: Text('Scan for the full profile. This card works offline — screenshot it or add it to your lock screen.', style: ppBody(12.5, color: ppSoft, h: 1.5))),
                    ]),
                  ]),
                ),
              ]),
            )),

            const SizedBox(height: 16),
            _pad(GestureDetector(
              onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Share / save to lock screen — coming soon'), behavior: SnackBarBehavior.floating)),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: ppBorder)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.ios_share_rounded, size: 17, color: ppPurple),
                  const SizedBox(width: 8),
                  Text('Share or save this card', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                ]),
              ),
            )),
          ],
        ),
      ),
    );
  }

  Widget _big(String label, String value, Color color) => Container(
        padding: const EdgeInsets.all(13),
        decoration: BoxDecoration(color: ppBg, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(), style: ppBody(9, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.5)),
          const SizedBox(height: 6),
          Text(value, style: ppJakarta(15, color: color), maxLines: 2, overflow: TextOverflow.ellipsis),
        ]),
      );

  Widget _row(IconData i, String label, String value) => Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(i, size: 16, color: ppMuted),
        const SizedBox(width: 10),
        Expanded(
          child: Text.rich(TextSpan(children: [
            TextSpan(text: '$label: ', style: ppBody(13, color: ppInk, w: FontWeight.w700)),
            TextSpan(text: value, style: ppBody(13, color: ppSoft)),
          ]), style: const TextStyle(height: 1.5)),
        ),
      ]);

  Widget _contact(EmergencyContact c) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(children: [
          const Icon(Icons.phone_outlined, size: 15, color: ppPurple),
          const SizedBox(width: 10),
          Expanded(child: Text('${c.name} · ${c.relation}', style: ppBody(13, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
          Text(c.phone, style: ppBody(12.5, color: ppSoft)),
        ]),
      );
}

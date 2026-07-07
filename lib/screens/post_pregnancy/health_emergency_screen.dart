// =============================================================================
//  HealthEmergencyScreen — the Emergency Card (create / edit / delete + share)
// -----------------------------------------------------------------------------
//  The one screen you can hand to anyone in a crisis: name, photo, DOB, weight,
//  blood group, allergies, emergency contacts, paediatrician and current meds.
//  Backed by the mutable HealthStore: the card can be created, edited, deleted,
//  and shared as text. Calm, clear, fast.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'pp_common.dart';
import 'pp_health_data.dart';

class HealthEmergencyScreen extends StatefulWidget {
  const HealthEmergencyScreen({super.key});

  @override
  State<HealthEmergencyScreen> createState() => _HealthEmergencyScreenState();
}

class _HealthEmergencyScreenState extends State<HealthEmergencyScreen> {
  static const Color _red = Color(0xFFB0402E);
  final _store = HealthStore.instance;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _store,
          builder: (context, _) {
            final e = _store.emergency;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Health')),
                const SizedBox(height: 18),
                _pad(Row(children: [
                  const Icon(Icons.emergency_outlined, size: 18, color: _red),
                  const SizedBox(width: 8),
                  Expanded(child: ppEyebrow('Emergency Card', color: _red, spacing: 1.2)),
                  if (e != null)
                    GestureDetector(
                      onTap: () => _editSheet(e),
                      behavior: HitTestBehavior.opaque,
                      child: Text('Edit', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                    ),
                ])),
                const SizedBox(height: 8),
                _pad(Text('In case of emergency', style: ppFraunces(28, h: 1.12))),
                const SizedBox(height: 6),
                _pad(Text('Everything a doctor or carer needs, fast — and available offline.', style: ppBody(14, h: 1.5))),
                const SizedBox(height: 20),
                if (e == null) _pad(_emptyState()) else ..._cardView(e),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _emptyState() => Column(children: [
        Container(
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(18)),
          child: Column(children: [
            const Icon(Icons.emergency_outlined, size: 30, color: _red),
            const SizedBox(height: 12),
            Text('No emergency card yet', style: ppJakarta(16)),
            const SizedBox(height: 6),
            Text('Create one so anyone can act fast in a crisis — even offline.', textAlign: TextAlign.center, style: ppBody(13, h: 1.5)),
          ]),
        ),
        const SizedBox(height: 16),
        GestureDetector(
          onTap: () => _editSheet(null),
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
            child: Text('Create emergency card', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
          ),
        ),
      ]);

  List<Widget> _cardView(EmergencyProfile e) => [
        _pad(Container(
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(22), border: Border.all(color: _red.withValues(alpha: 0.3)), boxShadow: ppCardShadow),
          clipBehavior: Clip.antiAlias,
          child: Column(children: [
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
        _pad(Row(children: [
          Expanded(
            child: GestureDetector(
              onTap: () => Share.share(_shareText(e)),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: ppBorder)),
                child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                  const Icon(Icons.ios_share_rounded, size: 17, color: ppPurple),
                  const SizedBox(width: 8),
                  Text('Share card', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                ]),
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: () => _confirmDelete(),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 52,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: ppBorder)),
              child: const Icon(Icons.delete_outline_rounded, size: 20, color: ppCoral),
            ),
          ),
        ])),
      ];

  String _shareText(EmergencyProfile e) => [
        'EMERGENCY CARD — ${e.name}',
        'Born ${e.dob} · ${e.weight}',
        'Blood group: ${e.bloodGroup}',
        'Allergies: ${e.allergies}',
        'Current medications: ${e.medications}',
        'Paediatrician: ${e.pediatrician}',
        'Emergency contacts:',
        for (final c in e.contacts) '  • ${c.name} (${c.relation}) — ${c.phone}',
      ].join('\n');

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

  // ---- create / edit ------------------------------------------------------
  void _editSheet(EmergencyProfile? existing) {
    final name = TextEditingController(text: existing?.name ?? '');
    final dob = TextEditingController(text: existing?.dob ?? '');
    final weight = TextEditingController(text: existing?.weight ?? '');
    final blood = TextEditingController(text: existing?.bloodGroup ?? '');
    final allergies = TextEditingController(text: existing?.allergies ?? 'None recorded');
    final ped = TextEditingController(text: existing?.pediatrician ?? '');
    final meds = TextEditingController(text: existing?.medications ?? 'None');

    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: SafeArea(
          top: false,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 16),
              Text(existing == null ? 'Create emergency card' : 'Edit emergency card', style: ppJakarta(18)),
              const SizedBox(height: 16),
              _tf(name, 'Child’s name'),
              _tf(dob, 'Date of birth'),
              _tf(weight, 'Weight'),
              _tf(blood, 'Blood group'),
              _tf(allergies, 'Allergies'),
              _tf(ped, 'Paediatrician (name · phone)'),
              _tf(meds, 'Current medications'),
              const SizedBox(height: 8),
              GestureDetector(
                onTap: () {
                  if (name.text.trim().isEmpty) return;
                  _store.setEmergency(EmergencyProfile(
                    name: name.text.trim(),
                    dob: dob.text.trim(),
                    weight: weight.text.trim(),
                    bloodGroup: blood.text.trim(),
                    allergies: allergies.text.trim(),
                    pediatrician: ped.text.trim(),
                    medications: meds.text.trim(),
                    contacts: existing?.contacts ?? const [],
                  ));
                  Navigator.of(ctx).pop();
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                  child: Text('Save', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  Widget _tf(TextEditingController c, String label) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label, style: ppBody(12, color: ppSoft, w: FontWeight.w700)),
          const SizedBox(height: 6),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppLine)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: c,
              style: ppBody(14, color: ppInk),
              decoration: const InputDecoration(isDense: true, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ]),
      );

  void _confirmDelete() {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text('Delete the emergency card?', style: ppJakarta(16)),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppLine)), child: Text('Cancel', style: ppBody(14, color: ppInk, w: FontWeight.w700))),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    _store.clearEmergency();
                    Navigator.of(ctx).pop();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: ppCoral, borderRadius: BorderRadius.circular(14)), child: Text('Delete', style: ppBody(14, color: Colors.white, w: FontWeight.w700))),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }
}

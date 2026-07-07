// =============================================================================
//  DoctorRecordScreen — the "Doctor-ready record" (a shareable summary)
// -----------------------------------------------------------------------------
//  Compiles one clean, hand-to-the-doctor summary from the child's health data:
//  vaccinations, growth, allergies, medical history / medications, recent
//  illnesses and reports. Reflects any edits made in the Health module (reads the
//  live HealthStore) and can be shared as text. Reached from the Vaccination
//  home's "Doctor-ready record" row and the Health module.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'pp_common.dart';
import 'pp_health_data.dart';

class DoctorRecordScreen extends StatelessWidget {
  const DoctorRecordScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    final store = HealthStore.instance;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: store,
          builder: (context, _) {
            final vaccinations = kHealthTimeline.where((e) => e.type == HealthEventType.vaccination && !e.upcoming).toList()..sort((a, b) => b.sortKey.compareTo(a.sortKey));
            final illnesses = kHealthTimeline.where((e) => e.type == HealthEventType.illness).toList()..sort((a, b) => b.sortKey.compareTo(a.sortKey));
            final latest = kGrowth.last;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Back')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('For your next visit', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('Doctor-ready record', style: ppFraunces(28, h: 1.12))),
                const SizedBox(height: 6),
                _pad(Text('A clean summary of Aarav’s health so far — everything a doctor might ask, in one place.', style: ppBody(14, h: 1.5))),

                const SizedBox(height: 20),
                _pad(_headerCard()),

                _section('Vaccinations', Icons.vaccines_outlined, [
                  _line('Status', 'On track · 13 of 18 first-year vaccines given'),
                  _line('Next due', 'PCV dose 3 · 22 Jul 2026'),
                  for (final v in vaccinations) _line(v.date, v.title),
                ]),

                _section('Growth', Icons.straighten_outlined, [
                  _line('At ${latest.ageLabel}', '${latest.weightKg} kg · ${latest.heightCm} cm · head ${latest.headCm} cm'),
                  _line('Centile', '${latest.weightPct}th (weight), tracking steadily'),
                ]),

                _section('Allergies', Icons.shield_outlined, store.allergies.isEmpty
                    ? [_line('Recorded', 'None')]
                    : [for (final a in store.allergies) _line(a.name, [a.severity, a.note].where((s) => s.isNotEmpty).join(' · '))]),

                _section('Medications & history', Icons.medication_outlined, store.medications.isEmpty
                    ? [_line('Recorded', 'None')]
                    : [for (final m in store.medications) _line(m.name, '${m.reason} · ${m.dosage} · ${m.completed ? 'completed' : 'ongoing'}')]),

                _section('Recent illnesses', Icons.sick_outlined, illnesses.isEmpty
                    ? [_line('Recorded', 'None')]
                    : [for (final e in illnesses) _line(e.date, '${e.title} — ${e.summary}')]),

                _section('Reports', Icons.description_outlined, store.reports.isEmpty
                    ? [_line('Recorded', 'None')]
                    : [for (final r in store.reports) _line(r.date, '${r.name}${r.summary.isNotEmpty ? ' — ${r.summary}' : ''}')]),

                const SizedBox(height: 24),
                _pad(GestureDetector(
                  onTap: () => Share.share(_shareText(store, vaccinations, illnesses, latest)),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 52,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(Icons.ios_share_rounded, size: 18, color: Colors.white),
                      const SizedBox(width: 8),
                      Text('Share this record', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                    ]),
                  ),
                )),
                const SizedBox(height: 14),
                _pad(Text('A summary for your convenience — your paediatrician’s own records remain the source of truth.',
                    textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _headerCard() => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair), boxShadow: ppCardShadow),
        child: Row(children: [
          Container(width: 54, height: 54, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)), clipBehavior: Clip.antiAlias, child: const PpStriped(height: 58)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Aarav', style: ppFraunces(22, h: 1.05)),
              const SizedBox(height: 3),
              Text('Born 8 March 2026 · 4 months · B+', style: ppBody(12.5, color: ppSoft)),
            ]),
          ),
        ]),
      );

  Widget _section(String title, IconData icon, List<Widget> rows) => Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _pad(Row(children: [
            Icon(icon, size: 18, color: ppPurple),
            const SizedBox(width: 10),
            Text(title, style: ppJakarta(16)),
          ])),
          const SizedBox(height: 12),
          _pad(Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(children: rows),
          )),
        ]),
      );

  Widget _line(String label, String value) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: ppHair))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 96, child: Text(label, style: ppBody(12, color: ppMuted, w: FontWeight.w700))),
          const SizedBox(width: 10),
          Expanded(child: Text(value.isEmpty ? '—' : value, style: ppBody(13, color: ppInk, h: 1.45))),
        ]),
      );

  String _shareText(HealthStore store, List<HealthEvent> vax, List<HealthEvent> illnesses, GrowthPoint latest) {
    final b = StringBuffer()
      ..writeln('DOCTOR-READY RECORD — Aarav')
      ..writeln('Born 8 March 2026 · 4 months · Blood group B+')
      ..writeln('')
      ..writeln('VACCINATIONS')
      ..writeln('  Status: on track · 13 of 18 first-year vaccines given')
      ..writeln('  Next due: PCV dose 3 · 22 Jul 2026');
    for (final v in vax) {
      b.writeln('  ${v.date}: ${v.title}');
    }
    b
      ..writeln('')
      ..writeln('GROWTH (at ${latest.ageLabel})')
      ..writeln('  ${latest.weightKg} kg · ${latest.heightCm} cm · head ${latest.headCm} cm (${latest.weightPct}th centile)')
      ..writeln('')
      ..writeln('ALLERGIES');
    if (store.allergies.isEmpty) {
      b.writeln('  None recorded');
    } else {
      for (final a in store.allergies) {
        b.writeln('  ${a.name} (${[a.severity, a.note].where((s) => s.isNotEmpty).join(' · ')})');
      }
    }
    b
      ..writeln('')
      ..writeln('MEDICATIONS & HISTORY');
    if (store.medications.isEmpty) {
      b.writeln('  None recorded');
    } else {
      for (final m in store.medications) {
        b.writeln('  ${m.name} — ${m.reason} · ${m.dosage} · ${m.completed ? 'completed' : 'ongoing'}');
      }
    }
    b
      ..writeln('')
      ..writeln('RECENT ILLNESSES');
    if (illnesses.isEmpty) {
      b.writeln('  None recorded');
    } else {
      for (final e in illnesses) {
        b.writeln('  ${e.date}: ${e.title} — ${e.summary}');
      }
    }
    b
      ..writeln('')
      ..writeln('REPORTS');
    if (store.reports.isEmpty) {
      b.writeln('  None recorded');
    } else {
      for (final r in store.reports) {
        b.writeln('  ${r.date}: ${r.name}${r.summary.isNotEmpty ? ' — ${r.summary}' : ''}');
      }
    }
    return b.toString();
  }
}

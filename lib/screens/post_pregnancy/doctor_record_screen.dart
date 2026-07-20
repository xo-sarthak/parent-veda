// =============================================================================
//  DoctorRecordScreen - the "Doctor-ready record" (a shareable summary)
// -----------------------------------------------------------------------------
//  Compiles one clean, hand-to-the-doctor summary from the child's health data:
//  vaccinations, growth, allergies, medical history / medications, recent
//  illnesses and reports. Reflects any edits made in the Health module (reads the
//  live HealthStore) and can be shared as text. Reached from the Vaccination
//  home's "Doctor-ready record" row and the Health module.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import 'pp_child_profile.dart';
import 'pp_common.dart';
import 'pp_growth_data.dart';
import 'pp_health_data.dart';
import 'pp_vaccine_data.dart';

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
            // Everything below now reads what the PARENT recorded. This screen
            // used to compile a fictional child's record - kHealthTimeline
            // vaccinations, a const kGrowth measurement, a hardcoded name,
            // birth date, blood group and "13 of 18 vaccines given" - under the
            // heading "Doctor-ready record". A parent could have handed a
            // doctor numbers belonging to nobody. Empty sections now say so.
            final child = ChildProfileStore.instance;
            final vax = VaxStore.instance;
            final growth = GrowthStore.instance;

            final givenVisits = kVaxVisits
                .where((v) => vax.statusOf(v) == VaxStatus.done)
                .toList()
              ..sort((a, b) => a.ageDays.compareTo(b.ageDays));
            final latest = growth.latest;
            return ListView(
              padding: const EdgeInsets.only(top: 12, bottom: 40),
              children: [
                _pad(ppBack(context, 'Back')),
                const SizedBox(height: 18),
                _pad(ppEyebrow('For your next visit', color: ppPurple)),
                const SizedBox(height: 8),
                _pad(Text('Doctor-ready record', style: ppFraunces(28, h: 1.12))),
                const SizedBox(height: 6),
                _pad(Text('A clean summary of ${child.name}’s health so far - everything a doctor might ask, in one place.', style: ppBody(14, h: 1.5))),

                const SizedBox(height: 20),
                _pad(_headerCard(child)),

                _section('Vaccinations', Icons.vaccines_outlined, givenVisits.isEmpty
                    ? [_line('Recorded', 'None marked yet')]
                    : [
                        _line('Recorded', '${vax.completedVaccineCount} ${vax.completedVaccineCount == 1 ? 'vaccine' : 'vaccines'} marked given'),
                        for (final v in givenVisits) _line(v.ageLabel, v.vaccines.map((x) => x.shortName).join(', ')),
                      ]),

                _section('Growth', Icons.straighten_outlined, latest == null
                    ? [_line('Recorded', 'No measurements yet')]
                    : [
                        _line('At ${latest.ageLabelAt(child.dob)}',
                            '${_trim(latest.weightKg)} kg · ${_trim(latest.heightCm)} cm${latest.headCm != null ? ' · head ${_trim(latest.headCm!)} cm' : ''}'),
                        if (growth.latestPercentilePhrase(GrowthMetric.weight) != null)
                          _line('Centile', '${growth.latestPercentilePhrase(GrowthMetric.weight)} (weight)'),
                      ]),

                _section('Allergies', Icons.shield_outlined, store.allergies.isEmpty
                    ? [_line('Recorded', 'None')]
                    : [for (final a in store.allergies) _line(a.name, [a.severity, a.note].where((s) => s.isNotEmpty).join(' · '))]),

                _section('Medications & history', Icons.medication_outlined, store.medications.isEmpty
                    ? [_line('Recorded', 'None')]
                    : [for (final m in store.medications) _line(m.name, '${m.reason} · ${m.dosage} · ${m.completed ? 'completed' : 'ongoing'}')]),

                // Symptoms she logged herself - the old version listed illnesses
                // from the seeded kHealthTimeline, i.e. another child's history.
                _section('Recent illnesses', Icons.sick_outlined, store.symptoms.isEmpty
                    ? [_line('Recorded', 'None')]
                    : [for (final s in store.symptoms) _line(s.date, [s.name, s.note].where((x) => x.isNotEmpty).join(' - '))]),

                _section('Reports', Icons.description_outlined, store.reports.isEmpty
                    ? [_line('Recorded', 'None')]
                    : [for (final r in store.reports) _line(r.date, '${r.name}${r.summary.isNotEmpty ? ' - ${r.summary}' : ''}')]),

                const SizedBox(height: 24),
                _pad(GestureDetector(
                  onTap: () => Share.share(_shareText(store, child, givenVisits, latest)),
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
                _pad(Text('A summary for your convenience - your paediatrician’s own records remain the source of truth.',
                    textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
              ],
            );
          },
        ),
      ),
    );
  }

  /// "6.4" not "6.40" - drop a trailing .0 so measurements read naturally.
  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  static const List<String> _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  static String _born(DateTime d) =>
      '${d.day} ${_months[d.month - 1]} ${d.year}';

  /// The header line: real name, real date of birth, real age. Blood group is
  /// shown ONLY if she recorded one on the emergency card - it used to be a
  /// hardcoded "B+", which is exactly the kind of invented clinical detail a
  /// doctor-facing screen must never carry.
  static String _headerLine(ChildProfileStore child) {
    final blood = HealthStore.instance.emergency?.bloodGroup ?? '';
    return [
      'Born ${_born(child.dob)}',
      child.ageLabel,
      if (blood.trim().isNotEmpty) blood,
    ].join(' · ');
  }

  Widget _headerCard(ChildProfileStore child) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair), boxShadow: ppCardShadow),
        child: Row(children: [
          Container(width: 54, height: 54, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)), clipBehavior: Clip.antiAlias, child: const PpStriped(height: 58)),
          const SizedBox(width: 16),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(child.name, style: ppFraunces(22, h: 1.05)),
              const SizedBox(height: 3),
              Text(_headerLine(child), style: ppBody(12.5, color: ppSoft)),
            ]),
          ),
        ]),
      );

  Widget _section(String title, IconData icon, List<Widget> rows) => Padding(
        padding: const EdgeInsets.only(top: 24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Flexible + ellipsis: a long section title ("Medications & history")
          // overflowed this row. It was invisible until the empty states made
          // the sections short enough for the lazy ListView to lay this one out.
          _pad(Row(children: [
            Icon(icon, size: 18, color: ppPurple),
            const SizedBox(width: 10),
            Flexible(
              child: Text(title, style: ppJakarta(16),
                  maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
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
          Expanded(child: Text(value.isEmpty ? '-' : value, style: ppBody(13, color: ppInk, h: 1.45))),
        ]),
      );

  // The SHARED text is the version that actually reaches a doctor, so it gets
  // the same treatment as the screen: real values, or an explicit "none
  // recorded". Nothing here may be invented.
  String _shareText(
    HealthStore store,
    ChildProfileStore child,
    List<VaxVisit> givenVisits,
    GrowthMeasurement? latest,
  ) {
    final vax = VaxStore.instance;
    final b = StringBuffer()
      ..writeln('DOCTOR-READY RECORD - ${child.name}')
      ..writeln(_headerLine(child))
      ..writeln('')
      ..writeln('VACCINATIONS');
    if (givenVisits.isEmpty) {
      b.writeln('  None marked yet');
    } else {
      b.writeln('  ${vax.completedVaccineCount} marked given');
      for (final v in givenVisits) {
        b.writeln('  ${v.ageLabel}: ${v.vaccines.map((x) => x.shortName).join(', ')}');
      }
    }
    b.writeln('');
    if (latest == null) {
      b.writeln('GROWTH');
      b.writeln('  No measurements recorded yet');
    } else {
      final pct = GrowthStore.instance.latestPercentilePhrase(GrowthMetric.weight);
      b.writeln('GROWTH (at ${latest.ageLabelAt(child.dob)})');
      b.writeln('  ${_trim(latest.weightKg)} kg · ${_trim(latest.heightCm)} cm'
          '${latest.headCm != null ? ' · head ${_trim(latest.headCm!)} cm' : ''}'
          '${pct != null ? ' ($pct centile)' : ''}');
    }
    b
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
        b.writeln('  ${m.name} - ${m.reason} · ${m.dosage} · ${m.completed ? 'completed' : 'ongoing'}');
      }
    }
    b
      ..writeln('')
      ..writeln('RECENT ILLNESSES');
    if (store.symptoms.isEmpty) {
      b.writeln('  None recorded');
    } else {
      for (final s in store.symptoms) {
        b.writeln('  ${s.date}: ${[s.name, s.note].where((x) => x.isNotEmpty).join(' - ')}');
      }
    }
    b
      ..writeln('')
      ..writeln('REPORTS');
    if (store.reports.isEmpty) {
      b.writeln('  None recorded');
    } else {
      for (final r in store.reports) {
        b.writeln('  ${r.date}: ${r.name}${r.summary.isNotEmpty ? ' - ${r.summary}' : ''}');
      }
    }
    return b.toString();
  }
}

// =============================================================================
//  HealthDoctorVisitScreen - the Doctor Visit Companion (a key differentiator)
// -----------------------------------------------------------------------------
//  Generates a clean, shareable summary before an appointment - age, growth,
//  vaccinations, current medications, allergies, recent history, recent reports -
//  plus the questions the parent saved for the doctor. Formatted like a printable
//  sheet; PDF share is stubbed. Never a diagnosis - just organised facts.
// =============================================================================

import 'package:flutter/material.dart';
import 'pp_child_profile.dart';
import 'package:share_plus/share_plus.dart';

import 'pp_common.dart';
import 'pp_growth_data.dart';
import 'pp_health_data.dart';
import 'pp_vaccine_data.dart';

class HealthDoctorVisitScreen extends StatefulWidget {
  const HealthDoctorVisitScreen({super.key});

  @override
  State<HealthDoctorVisitScreen> createState() => _HealthDoctorVisitScreenState();
}

class _HealthDoctorVisitScreenState extends State<HealthDoctorVisitScreen> {
  final TextEditingController _q = TextEditingController();
  HealthStore get _s => HealthStore.instance;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  // Every line below is HER record. This screen used to print a fictional
  // child - "4 months (born 8 Mar 2026) · Boy", a const growth measurement,
  // "Up to date", "Vitamin D drops", "Mild cold (early Jun)" - and hand it to a
  // doctor via the Share button. Same fix as the Doctor-ready record.
  static const List<String> _months = [
    'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',
  ];
  static String _trim(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

  String _childLine() {
    final c = ChildProfileStore.instance;
    final d = c.dob;
    return '${c.name} · ${c.ageLabel} '
        '(born ${d.day} ${_months[d.month - 1]} ${d.year}) · '
        '${c.isBoy ? 'Boy' : 'Girl'}';
  }

  String _growthLine() {
    final m = GrowthStore.instance.latest;
    if (m == null) return 'No measurements recorded yet';
    final pct = GrowthStore.instance.latestPercentilePhrase(GrowthMetric.weight);
    return '${_trim(m.weightKg)} kg${pct != null ? ' ($pct)' : ''} · '
        '${_trim(m.heightCm)} cm'
        '${m.headCm != null ? ' · head ${_trim(m.headCm!)} cm' : ''}';
  }

  String _vaxLine() {
    final v = VaxStore.instance;
    final done = kVaxVisits.where((x) => v.statusOf(x) == VaxStatus.done).length;
    if (done == 0) return 'None marked yet';
    final next = v.dueVisit ?? v.nextVisit;
    return '$done of ${kVaxVisits.length} visits marked'
        '${next != null ? ' · next: ${next.lead.shortName} (${next.ageLabel})' : ''}';
  }

  String _medsLine() => _s.medications.isEmpty
      ? 'None recorded'
      : _s.medications.map((m) => '${m.name} (${m.dosage})').join(' · ');

  String _allergyLine() => _s.allergies.isEmpty
      ? 'None recorded'
      : _s.allergies.map((a) => a.name).join(' · ');

  String _historyLine() => _s.symptoms.isEmpty
      ? 'None recorded'
      : _s.symptoms.take(3).map((x) => '${x.name} (${x.date})').join(' · ');

  String _reportsLine() => _s.reports.isEmpty
      ? 'None recorded'
      : _s.reports.take(3).map((r) => '${r.name} (${r.date})').join(' · ');

  String _shareText() {
    final b = StringBuffer()
      ..writeln('VISIT SUMMARY - ${ChildProfileStore.instance.name}')
      ..writeln('Child: ${_childLine()}')
      ..writeln('Growth: ${_growthLine()}')
      ..writeln('Vaccinations: ${_vaxLine()}')
      ..writeln('Medications: ${_medsLine()}')
      ..writeln('Allergies: ${_allergyLine()}')
      ..writeln('Recent history: ${_historyLine()}')
      ..writeln('Recent reports: ${_reportsLine()}')
      ..writeln('')
      ..writeln('QUESTIONS TO ASK');
    for (final q in _s.questions) {
      b.writeln('  • $q');
    }
    return b.toString();
  }

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _s,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 40),
            children: [
              _pad(ppBack(context, 'Health')),
              const SizedBox(height: 18),
              _pad(ppEyebrow('Doctor Visit Companion', color: ppPurple)),
              const SizedBox(height: 8),
              _pad(Text('Ready for the appointment', style: ppFraunces(28, h: 1.12))),
              const SizedBox(height: 6),
              _pad(Text('Everything the paediatrician needs, gathered for you - bring it, or share it ahead.', style: ppBody(14, h: 1.5))),

              const SizedBox(height: 20),
              // the printable summary sheet
              _pad(Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair), boxShadow: ppCardShadow),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    const Icon(Icons.summarize_outlined, size: 18, color: ppPurple),
                    const SizedBox(width: 8),
                    Expanded(child: ppEyebrow('Visit summary', color: ppPurple, spacing: 0.8)),
                    const SizedBox(width: 8),
                    Text('Prepared today', style: ppBody(11, color: ppMuted)),
                  ]),
                  const SizedBox(height: 14),
                  _line('Child', _childLine()),
                  _line('Growth', _growthLine()),
                  _line('Vaccinations', _vaxLine()),
                  _line('Medications', _medsLine()),
                  _line('Allergies', _allergyLine()),
                  _line('Recent history', _historyLine()),
                  _line('Recent reports', _reportsLine(), last: true),
                ]),
              )),

              const SizedBox(height: 24),
              _pad(Text('Questions to ask', style: ppJakarta(18))),
              const SizedBox(height: 4),
              _pad(Text('Save them now, so nothing slips your mind in the room.', style: ppBody(12.5, color: ppMuted))),
              const SizedBox(height: 14),
              _pad(Column(children: [for (int i = 0; i < _s.questions.length; i++) _questionRow(i, _s.questions[i])])),
              const SizedBox(height: 4),
              _pad(_addQuestion()),

              const SizedBox(height: 24),
              _pad(GestureDetector(
                onTap: () => Share.share(_shareText()),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.ios_share_rounded, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Text('Share with paediatrician', style: ppBody(13.5, color: Colors.white, w: FontWeight.w700)),
                  ]),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }

  Widget _line(String label, String value, {bool last = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(border: Border(bottom: last ? BorderSide.none : const BorderSide(color: ppHair))),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(width: 108, child: Text(label, style: ppBody(12.5, color: ppMuted, w: FontWeight.w700))),
          const SizedBox(width: 10),
          Expanded(child: Text(value, style: ppBody(13.5, color: ppInk, h: 1.45, w: FontWeight.w600))),
        ]),
      );

  Widget _questionRow(int i, String q) => Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(15, 13, 10, 13),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
        child: Row(children: [
          const Icon(Icons.help_outline_rounded, size: 16, color: ppPurple),
          const SizedBox(width: 12),
          Expanded(child: Text(q, style: ppBody(13.5, color: ppInk, h: 1.4))),
          GestureDetector(onTap: () => _s.removeQuestion(i), behavior: HitTestBehavior.opaque, child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close_rounded, size: 16, color: ppMuted))),
        ]),
      );

  Widget _addQuestion() => Row(children: [
        Expanded(
          child: TextField(
            controller: _q,
            style: ppBody(14, color: ppInk),
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'Add a question…',
              hintStyle: ppBody(14, color: ppMuted),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: ppHair)),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: ppHair)),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: ppPurple)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _submit,
          child: Container(width: 44, height: 44, alignment: Alignment.center, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle), child: const Icon(Icons.add_rounded, size: 22, color: Colors.white)),
        ),
      ]);

  void _submit() {
    _s.addQuestion(_q.text);
    _q.clear();
  }
}

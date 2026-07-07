// =============================================================================
//  HealthRecordsScreen — one Medical History category, organised (not folders)
// -----------------------------------------------------------------------------
//  Renders a single category — Doctor visits / Medications / Reports / Symptoms /
//  Allergies — as clean, understandable cards with a search field and thoughtful
//  empty states. Reports show extracted values (with any abnormal flags); the
//  symptom list carries a gentle pattern note. Uploading a report is stubbed.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_health_data.dart';

class HealthRecordsScreen extends StatefulWidget {
  const HealthRecordsScreen({super.key, required this.category});
  final String category; // visits | medications | reports | symptoms | allergies

  @override
  State<HealthRecordsScreen> createState() => _HealthRecordsScreenState();
}

class _HealthRecordsScreenState extends State<HealthRecordsScreen> {
  String _q = '';

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  bool _match(String s) => _q.isEmpty || s.toLowerCase().contains(_q.toLowerCase());
  void _soon(String m) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  String get _title => switch (widget.category) {
        'visits' => 'Doctor visits',
        'medications' => 'Medications',
        'reports' => 'Reports',
        'symptoms' => 'Symptoms',
        'allergies' => 'Allergies',
        _ => 'Records',
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Health')),
            const SizedBox(height: 18),
            _pad(ppEyebrow('Medical history', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text(_title, style: ppFraunces(28, h: 1.12))),
            const SizedBox(height: 16),
            _pad(_search()),
            const SizedBox(height: 20),
            ..._body(),
          ],
        ),
      ),
    );
  }

  Widget _search() => Container(
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppLine)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        child: Row(children: [
          const Icon(Icons.search_rounded, size: 18, color: ppMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              onChanged: (v) => setState(() => _q = v),
              style: ppBody(14, color: ppInk),
              decoration: InputDecoration(isDense: true, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 13), hintText: 'Search ${_title.toLowerCase()}…', hintStyle: ppBody(14, color: ppMuted)),
            ),
          ),
        ]),
      );

  List<Widget> _body() {
    switch (widget.category) {
      case 'medications':
        return _list([for (final m in kMedications) if (_match('${m.name} ${m.reason} ${m.doctor}')) _medCard(m)], 'No medications recorded.');
      case 'reports':
        return [
          ...[for (final r in kReports) if (_match('${r.name} ${r.summary}')) _pad(_reportCard(r))],
          _pad(_uploadRow()),
        ];
      case 'symptoms':
        return [
          _pad(Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.auto_awesome, size: 15, color: ppPurple),
              const SizedBox(width: 10),
              Expanded(child: Text('So far, his symptoms have been limited to a single mild cold and a brief post-vaccine fever — both common and self-limiting.', style: ppBody(12.5, h: 1.5))),
            ]),
          )),
          const SizedBox(height: 16),
          ..._list([for (final s in kSymptoms) if (_match('${s.name} ${s.note}')) _symptomCard(s)], 'No symptoms recorded.'),
        ];
      case 'allergies':
        return _allergies();
      case 'visits':
      default:
        final visits = kHealthTimeline.where((e) => e.type == HealthEventType.doctorVisit || e.type == HealthEventType.growthCheck).toList()..sort((a, b) => b.sortKey.compareTo(a.sortKey));
        return _list([for (final e in visits) if (_match('${e.title} ${e.summary} ${e.doctor ?? ''}')) _visitCard(e)], 'No visits recorded.');
    }
  }

  List<Widget> _list(List<Widget> cards, String emptyMsg) {
    if (cards.isEmpty) return [_pad(_empty(emptyMsg))];
    return [_pad(Column(children: cards))];
  }

  Widget _empty(String msg) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
        child: Text(msg, style: ppBody(13.5, color: ppMuted, h: 1.5)),
      );

  Widget _card(Widget child) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
        child: child,
      );

  Widget _medCard(Medication m) => _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Expanded(child: Text(m.name, style: ppJakarta(14.5))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
            decoration: BoxDecoration(color: (m.completed ? ppMuted : ppPurple).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
            child: Text(m.completed ? 'Completed' : 'Ongoing', style: ppBody(10.5, color: m.completed ? ppSoft : ppPurple, w: FontWeight.w700)),
          ),
        ]),
        const SizedBox(height: 6),
        Text(m.reason, style: ppBody(13, h: 1.4)),
        const SizedBox(height: 8),
        Text('${m.dosage} · ${m.duration}', style: ppBody(12, color: ppSoft)),
        const SizedBox(height: 3),
        Text('${m.doctor} · ${m.date}', style: ppBody(11.5, color: ppMuted)),
      ]));

  Widget _visitCard(HealthEvent e) => _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(e.title, style: ppJakarta(14.5))), Text(e.date, style: ppBody(11, color: ppMuted))]),
        const SizedBox(height: 6),
        Text(e.summary, style: ppBody(13, h: 1.5)),
        if (e.doctor != null) ...[const SizedBox(height: 8), Text(e.doctor!, style: ppBody(11.5, color: ppMuted))],
      ]));

  Widget _symptomCard(SymptomEntry s) => _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [Expanded(child: Text(s.name, style: ppJakarta(14.5))), Text(s.date, style: ppBody(11, color: ppMuted))]),
        const SizedBox(height: 5),
        Text(s.note, style: ppBody(13, h: 1.4)),
      ]));

  Widget _reportCard(MedicalReport r) => _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.description_outlined, size: 18, color: ppPurple)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.name, style: ppJakarta(14.5), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${r.date}${r.doctor != null ? ' · ${r.doctor}' : ''}', style: ppBody(11.5, color: ppMuted)),
          ])),
        ]),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(color: ppBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppHair)),
          child: Column(children: [
            for (final v in r.values)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(children: [
                  Expanded(child: Text(v.label, style: ppBody(12.5, color: ppSoft))),
                  Text(v.value, style: ppBody(12.5, color: v.flag == 'normal' ? ppInk : ppCoral, w: FontWeight.w700)),
                ]),
              ),
          ]),
        ),
        const SizedBox(height: 10),
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.auto_awesome, size: 14, color: ppPurple),
          const SizedBox(width: 8),
          Expanded(child: Text(r.summary, style: ppBody(12.5, color: ppInk, h: 1.5))),
        ]),
      ]));

  Widget _uploadRow() => GestureDetector(
        onTap: () => _soon('Report upload — extracting values automatically is coming soon'),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: ppBorder)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.upload_file_outlined, size: 18, color: ppPurple),
            const SizedBox(width: 8),
            Text('Upload a report', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
          ]),
        ),
      );

  List<Widget> _allergies() {
    final known = kAllergies.where((a) => a.status == AllergyStatus.known).toList();
    return [
      _pad(Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
        child: Row(children: [
          Container(width: 42, height: 42, alignment: Alignment.center, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle), child: const Icon(Icons.shield_outlined, size: 20, color: ppPurple)),
          const SizedBox(width: 14),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(known.isEmpty ? 'No known allergies' : '${known.length} known ${known.length == 1 ? 'allergy' : 'allergies'}', style: ppJakarta(15)),
            const SizedBox(height: 3),
            Text('As new foods are introduced, note anything here so it’s never forgotten.', style: ppBody(12.5, h: 1.4)),
          ])),
        ]),
      )),
      const SizedBox(height: 14),
      if (known.isNotEmpty) _pad(Column(children: [for (final a in known) _card(Text(a.name, style: ppJakarta(14)))])),
      _pad(GestureDetector(
        onTap: () => _soon('Add an allergy — coming soon'),
        behavior: HitTestBehavior.opaque,
        child: Row(children: [const Icon(Icons.add_rounded, size: 18, color: ppPurple), const SizedBox(width: 8), Text('Add an allergy', style: ppBody(13, color: ppPurple, w: FontWeight.w700))]),
      )),
    ];
  }
}

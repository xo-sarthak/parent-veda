// =============================================================================
//  HealthRecordsScreen - one Medical History category, with full CRUD
// -----------------------------------------------------------------------------
//  Renders a single category - Doctor visits / Medications / Reports / Symptoms /
//  Allergies - as clean cards with search and thoughtful empty states, backed by
//  the mutable HealthStore. Every section offers an obvious way to add to it, and
//  editable cards carry a visible "Edit". Visits, medications, allergies and
//  symptoms can be added, edited and deleted; reports can be added and deleted.
//  Seeded visits from the health timeline still show here, tagged read-only.
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
  final _store = HealthStore.instance;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  bool _match(String s) => _q.isEmpty || s.toLowerCase().contains(_q.toLowerCase());

  String get _title => switch (widget.category) {
        'visits' => 'Doctor visits',
        'medications' => 'Medications',
        'reports' => 'Reports',
        'symptoms' => 'Symptoms',
        'allergies' => 'Allergies',
        _ => 'Records',
      };

  static String _today() {
    final d = DateTime.now();
    const m = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: _store,
          builder: (context, _) => ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 40),
            children: [
              _pad(ppBack(context, 'Health')),
              const SizedBox(height: 18),
              _pad(ppEyebrow('Medical history', color: ppPurple)),
              const SizedBox(height: 8),
              _pad(Text(_title, style: ppFraunces(28, h: 1.12))),
              const SizedBox(height: 16),
              _pad(_search()),
              const SizedBox(height: 16),
              if (_addLabel != null) ...[
                _pad(_addButton(_addLabel!, _onAdd)),
                const SizedBox(height: 16),
              ],
              ..._body(),
            ],
          ),
        ),
      ),
    );
  }

  String? get _addLabel => switch (widget.category) {
        'visits' => 'Add a visit',
        'medications' => 'Add medication',
        'reports' => 'Add a report',
        'symptoms' => 'Log a symptom',
        'allergies' => 'Add an allergy',
        _ => null,
      };

  void _onAdd() {
    switch (widget.category) {
      case 'visits':
        _visitSheet();
      case 'medications':
        _medSheet();
      case 'reports':
        _reportSheet();
      case 'symptoms':
        _symptomSheet();
      case 'allergies':
        _allergySheet();
    }
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
              decoration: InputDecoration(isDense: true, filled: false, border: InputBorder.none, contentPadding: const EdgeInsets.symmetric(vertical: 13), hintText: 'Search ${_title.toLowerCase()}…', hintStyle: ppBody(14, color: ppMuted)),
            ),
          ),
        ]),
      );

  Widget _addButton(String label, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          alignment: Alignment.center,
          decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: ppBorder)),
          child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
            const Icon(Icons.add_rounded, size: 18, color: ppPurple),
            const SizedBox(width: 8),
            Text(label, style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
          ]),
        ),
      );

  List<Widget> _body() {
    switch (widget.category) {
      case 'medications':
        final meds = _store.medications;
        final cards = [for (int i = 0; i < meds.length; i++) if (_match('${meds[i].name} ${meds[i].reason} ${meds[i].doctor}')) _medCard(meds[i], i)];
        return _list(cards, 'No medications recorded yet.');
      case 'reports':
        final reports = _store.reports;
        return [for (int i = 0; i < reports.length; i++) if (_match('${reports[i].name} ${reports[i].summary}')) _pad(_reportCard(reports[i], i))];
      case 'symptoms':
        final syms = _store.symptoms;
        return [
          _pad(Container(
            padding: const EdgeInsets.all(15),
            decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.auto_awesome, size: 15, color: ppPurple),
              const SizedBox(width: 10),
              Expanded(child: Text('Log anything you notice - a temperature, a rash, a rough night. A clear record helps you and the doctor spot patterns.', style: ppBody(12.5, h: 1.5))),
            ]),
          )),
          const SizedBox(height: 16),
          ..._list([for (int i = 0; i < syms.length; i++) if (_match('${syms[i].name} ${syms[i].note}')) _symptomCard(syms[i], i)], 'No symptoms logged yet.'),
        ];
      case 'allergies':
        return _allergies();
      case 'visits':
      default:
        final added = _store.visits; // parent-added, editable
        final timeline = kHealthTimeline.where((e) => e.type == HealthEventType.doctorVisit || e.type == HealthEventType.growthCheck).toList()
          ..sort((a, b) => b.sortKey.compareTo(a.sortKey)); // seeded, read-only
        final cards = <Widget>[
          for (int i = 0; i < added.length; i++)
            if (_match('${added[i].title} ${added[i].summary} ${added[i].doctor ?? ''}')) _visitCard(added[i], index: i),
          for (final e in timeline)
            if (_match('${e.title} ${e.summary} ${e.doctor ?? ''}')) _visitCard(e),
        ];
        return _list(cards, 'No visits recorded yet.');
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

  Widget _card(Widget child, {VoidCallback? onTap}) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
          child: child,
        ),
      );

  Widget _medCard(Medication m, int i) => _card(
        onTap: () => _medSheet(existing: m, index: i),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(m.name, style: ppJakarta(14.5))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(color: (m.completed ? ppMuted : ppPurple).withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
              child: Text(m.completed ? 'Completed' : 'Ongoing', style: ppBody(10.5, color: m.completed ? ppSoft : ppPurple, w: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            _editHint(),
          ]),
          const SizedBox(height: 6),
          Text(m.reason, style: ppBody(13, h: 1.4)),
          const SizedBox(height: 8),
          Text('${m.dosage} · ${m.duration}', style: ppBody(12, color: ppSoft)),
          const SizedBox(height: 3),
          Text('${m.doctor} · ${m.date}', style: ppBody(11.5, color: ppMuted)),
        ]),
      );

  // Parent-added visits (index != null) are editable; seeded timeline visits are
  // read-only and carry a small "From the timeline" tag so the difference is clear.
  Widget _visitCard(HealthEvent e, {int? index}) => _card(
        onTap: index == null ? null : () => _visitSheet(existing: e, index: index),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(e.title, style: ppJakarta(14.5))),
            const SizedBox(width: 8),
            Text(e.date, style: ppBody(11, color: ppMuted)),
          ]),
          const SizedBox(height: 6),
          Text(e.summary, style: ppBody(13, h: 1.5)),
          if (e.doctor != null) ...[const SizedBox(height: 8), Text(e.doctor!, style: ppBody(11.5, color: ppMuted))],
          const SizedBox(height: 8),
          index == null
              ? Row(children: [
                  const Icon(Icons.lock_outline_rounded, size: 12, color: ppMuted),
                  const SizedBox(width: 5),
                  Text('From the timeline', style: ppBody(10.5, color: ppMuted, w: FontWeight.w600)),
                ])
              : _editHint(),
        ]),
      );

  Widget _symptomCard(SymptomEntry s, int i) => _card(
        onTap: () => _symptomSheet(existing: s, index: i),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [Expanded(child: Text(s.name, style: ppJakarta(14.5))), Text(s.date, style: ppBody(11, color: ppMuted))]),
          const SizedBox(height: 5),
          Text(s.note, style: ppBody(13, h: 1.4)),
          const SizedBox(height: 8),
          _editHint(),
        ]),
      );

  Widget _reportCard(MedicalReport r, int i) => _card(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(11)), child: const Icon(Icons.description_outlined, size: 18, color: ppPurple)),
          const SizedBox(width: 12),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(r.name, style: ppJakarta(14.5), maxLines: 2, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${r.date}${r.doctor != null ? ' · ${r.doctor}' : ''}', style: ppBody(11.5, color: ppMuted)),
          ])),
          GestureDetector(
            onTap: () => _confirmDelete('Delete this report?', () => _store.removeReport(i)),
            behavior: HitTestBehavior.opaque,
            child: const Padding(padding: EdgeInsets.only(left: 6), child: Icon(Icons.delete_outline_rounded, size: 20, color: ppMuted)),
          ),
        ]),
        if (r.values.isNotEmpty) ...[
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
        ],
        if (r.summary.isNotEmpty) ...[
          const SizedBox(height: 10),
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            const Icon(Icons.auto_awesome, size: 14, color: ppPurple),
            const SizedBox(width: 8),
            Expanded(child: Text(r.summary, style: ppBody(12.5, color: ppInk, h: 1.5))),
          ]),
        ],
      ]));

  List<Widget> _allergies() {
    final all = _store.allergies;
    final known = _store.knownAllergies;
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
      if (all.isNotEmpty)
        _pad(Column(children: [
          for (int i = 0; i < all.length; i++)
            if (_match('${all[i].name} ${all[i].note}')) _allergyCard(all[i], i),
        ])),
    ];
  }

  Widget _allergyCard(Allergy a, int i) => _card(
        onTap: () => _allergySheet(existing: a, index: i),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(a.name, style: ppJakarta(14.5))),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
              decoration: BoxDecoration(color: ppPurple.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)),
              child: Text(_allergyStatusLabel(a.status), style: ppBody(10.5, color: ppPurple, w: FontWeight.w700)),
            ),
            const SizedBox(width: 8),
            _editHint(),
          ]),
          if (a.severity.isNotEmpty || a.note.isNotEmpty) ...[
            const SizedBox(height: 6),
            Text([if (a.severity.isNotEmpty) a.severity, if (a.note.isNotEmpty) a.note].join(' · '), style: ppBody(13, h: 1.4)),
          ],
        ]),
      );

  // =========================================================================
  //  Add / edit sheets
  // =========================================================================
  void _medSheet({Medication? existing, int? index}) {
    final name = TextEditingController(text: existing?.name ?? '');
    final reason = TextEditingController(text: existing?.reason ?? '');
    final dosage = TextEditingController(text: existing?.dosage ?? '');
    final duration = TextEditingController(text: existing?.duration ?? '');
    final doctor = TextEditingController(text: existing?.doctor ?? '');
    bool completed = existing?.completed ?? false;
    _sheet(
      title: existing == null ? 'Add medication' : 'Edit medication',
      onDelete: index == null ? null : () => _store.removeMedication(index),
      fields: (setSheet) => [
        _tf(name, 'Name'),
        _tf(reason, 'Reason'),
        _tf(dosage, 'Dosage'),
        _tf(duration, 'Duration'),
        _tf(doctor, 'Prescribed by'),
        _toggleRow('Completed', completed, (v) => setSheet(() => completed = v)),
      ],
      onSave: () {
        if (name.text.trim().isEmpty) return false;
        final m = Medication(
          name: name.text.trim(),
          reason: reason.text.trim(),
          doctor: doctor.text.trim().isEmpty ? '-' : doctor.text.trim(),
          dosage: dosage.text.trim(),
          duration: duration.text.trim(),
          completed: completed,
          date: existing?.date ?? _today(),
        );
        index == null ? _store.addMedication(m) : _store.updateMedication(index, m);
        return true;
      },
    );
  }

  void _allergySheet({Allergy? existing, int? index}) {
    final name = TextEditingController(text: existing?.name ?? '');
    final severity = TextEditingController(text: existing?.severity ?? '');
    final note = TextEditingController(text: existing?.note ?? '');
    AllergyStatus status = existing?.status ?? AllergyStatus.known;
    _sheet(
      title: existing == null ? 'Add allergy' : 'Edit allergy',
      onDelete: index == null ? null : () => _store.removeAllergy(index),
      fields: (setSheet) => [
        _tf(name, 'Allergen'),
        _label('Status'),
        _statusChips(status, (s) => setSheet(() => status = s)),
        const SizedBox(height: 12),
        _tf(severity, 'Severity (e.g. mild, severe)'),
        _tf(note, 'Note', maxLines: 3),
      ],
      onSave: () {
        if (name.text.trim().isEmpty) return false;
        final a = Allergy(name.text.trim(), status, severity.text.trim(), note.text.trim());
        index == null ? _store.addAllergy(a) : _store.updateAllergy(index, a);
        return true;
      },
    );
  }

  void _symptomSheet({SymptomEntry? existing, int? index}) {
    final name = TextEditingController(text: existing?.name ?? '');
    final note = TextEditingController(text: existing?.note ?? '');
    _sheet(
      title: existing == null ? 'Log a symptom' : 'Edit symptom',
      onDelete: index == null ? null : () => _store.removeSymptom(index),
      fields: (setSheet) => [
        _tf(name, 'Symptom (e.g. fever, rash)'),
        _tf(note, 'What you noticed', maxLines: 3),
      ],
      onSave: () {
        if (name.text.trim().isEmpty) return false;
        final s = SymptomEntry(name.text.trim(), existing?.date ?? _today(), note.text.trim());
        index == null ? _store.addSymptom(s) : _store.updateSymptom(index, s);
        return true;
      },
    );
  }

  void _visitSheet({HealthEvent? existing, int? index}) {
    final title = TextEditingController(text: existing?.title ?? '');
    final date = TextEditingController(text: existing?.date ?? _today());
    final doctor = TextEditingController(text: existing?.doctor ?? '');
    final summary = TextEditingController(text: existing?.summary ?? '');
    _sheet(
      title: existing == null ? 'Add a visit' : 'Edit visit',
      onDelete: index == null ? null : () => _store.removeVisit(index),
      fields: (setSheet) => [
        _tf(title, 'Visit (e.g. 6-month check, fever review)'),
        _tf(date, 'Date'),
        _tf(doctor, 'Doctor / clinic'),
        _tf(summary, 'What happened / advice', maxLines: 4),
      ],
      onSave: () {
        if (title.text.trim().isEmpty) return false;
        final v = HealthEvent(
          id: existing?.id ?? 'v_added_${DateTime.now().microsecondsSinceEpoch}',
          type: HealthEventType.doctorVisit,
          date: date.text.trim().isEmpty ? _today() : date.text.trim(),
          title: title.text.trim(),
          summary: summary.text.trim(),
          doctor: doctor.text.trim().isEmpty ? null : doctor.text.trim(),
          sortKey: 1000, // parent-added visits sort to the top of the list
        );
        index == null ? _store.addVisit(v) : _store.updateVisit(index, v);
        return true;
      },
    );
  }

  void _reportSheet() {
    final name = TextEditingController();
    final summary = TextEditingController();
    _sheet(
      title: 'Add a report',
      fields: (setSheet) => [
        _tf(name, 'Report name (e.g. Blood test)'),
        _tf(summary, 'Summary / key findings', maxLines: 4),
      ],
      onSave: () {
        if (name.text.trim().isEmpty) return false;
        _store.addReport(MedicalReport(name: name.text.trim(), date: _today(), summary: summary.text.trim()));
        return true;
      },
    );
  }

  // ---- sheet scaffolding --------------------------------------------------
  void _sheet({
    required String title,
    required List<Widget> Function(void Function(void Function())) fields,
    required bool Function() onSave,
    VoidCallback? onDelete,
  }) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
                const SizedBox(height: 16),
                Row(children: [
                  Expanded(child: Text(title, style: ppJakarta(18))),
                  if (onDelete != null)
                    GestureDetector(
                      onTap: () {
                        onDelete();
                        Navigator.of(ctx).pop();
                      },
                      behavior: HitTestBehavior.opaque,
                      child: const Icon(Icons.delete_outline_rounded, size: 22, color: ppCoral),
                    ),
                ]),
                const SizedBox(height: 16),
                ...fields(setSheet),
                const SizedBox(height: 20),
                GestureDetector(
                  onTap: () {
                    if (onSave()) Navigator.of(ctx).pop();
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
      ),
    );
  }

  void _confirmDelete(String title, VoidCallback onConfirm) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(title, style: ppJakarta(16)),
            const SizedBox(height: 18),
            Row(children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => Navigator.of(ctx).pop(),
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppLine)),
                    child: Text('Cancel', style: ppBody(14, color: ppInk, w: FontWeight.w700)),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: GestureDetector(
                  onTap: () {
                    onConfirm();
                    Navigator.of(ctx).pop();
                  },
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    height: 48,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(color: ppCoral, borderRadius: BorderRadius.circular(14)),
                    child: Text('Delete', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
                  ),
                ),
              ),
            ]),
          ]),
        ),
      ),
    );
  }

  // ---- small form parts ---------------------------------------------------
  Widget _label(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(t, style: ppBody(12, color: ppSoft, w: FontWeight.w700)),
      );

  // A visible "Edit" affordance on editable cards, so tapping to edit is obvious.
  Widget _editHint() => Row(mainAxisSize: MainAxisSize.min, children: [
        const Icon(Icons.edit_outlined, size: 13, color: ppPurple),
        const SizedBox(width: 4),
        Text('Edit', style: ppBody(11.5, color: ppPurple, w: FontWeight.w700)),
      ]);

  Widget _tf(TextEditingController c, String label, {int maxLines = 1}) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _label(label),
          Container(
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12), border: Border.all(color: ppLine)),
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: TextField(
              controller: c,
              maxLines: maxLines,
              style: ppBody(14, color: ppInk),
              decoration: const InputDecoration(isDense: true, filled: false, border: InputBorder.none, contentPadding: EdgeInsets.symmetric(vertical: 12)),
            ),
          ),
        ]),
      );

  Widget _toggleRow(String label, bool value, ValueChanged<bool> onChanged) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(children: [
          Expanded(child: Text(label, style: ppBody(14, color: ppInk, w: FontWeight.w600))),
          GestureDetector(onTap: () => onChanged(!value), behavior: HitTestBehavior.opaque, child: ppSwitch(value)),
        ]),
      );

  Widget _statusChips(AllergyStatus value, ValueChanged<AllergyStatus> onChanged) => Row(
        children: [
          for (final s in AllergyStatus.values)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: GestureDetector(
                onTap: () => onChanged(s),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 8),
                  decoration: BoxDecoration(
                    color: value == s ? ppPurple : Colors.white,
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: value == s ? ppPurple : ppLine),
                  ),
                  child: Text(_allergyStatusLabel(s), style: ppBody(12, color: value == s ? Colors.white : ppInk, w: FontWeight.w700)),
                ),
              ),
            ),
        ],
      );

  String _allergyStatusLabel(AllergyStatus s) => switch (s) {
        AllergyStatus.known => 'Known',
        AllergyStatus.suspected => 'Suspected',
        AllergyStatus.resolved => 'Resolved',
      };
}

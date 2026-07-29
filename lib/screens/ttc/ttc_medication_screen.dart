// =============================================================================
//  TTC Medication - what she is actually taking
// -----------------------------------------------------------------------------
//  The gap this closes (A-42) was the widest in the stage, and it sat directly
//  under the most careful thinking in it.
//
//  The whole care-pathway design turns on one question: HAS MEDICATION TAKEN
//  OVER WHEN OVULATION HAPPENS? We ask her that, in those words, and the answer
//  decides whether we predict a fertile window or defer to her clinic. Then the
//  "Medication" tile in Tools opened a curated supplement list with `+` buttons
//  and no text field anywhere. She could add *folic acid, from our list*. She
//  could not write down *Letrozole 2.5mg, days 3 to 7*.
//
//  A woman on a stimulation protocol carries four drugs on a schedule, and the
//  app that had just asked her about her medication could hold none of them.
//
//  ---------------------------------------------------------------------------
//  Why this uses MedicineStore rather than a new TTC store
//
//  `MedicineStore` lives in `lib/services/`, not in a stage folder, because a
//  medication is not a pregnancy concept or a TTC concept - it is a fact about a
//  person. It already has the model (name, dose, frequency, notes, start/end),
//  per-day "taken" logs, and real OS alarms with times, weekdays and windows.
//  Its tables already exist.
//
//  So this screen adds **no store, no table and no SQL**. It is a TTC-skinned
//  door onto infrastructure the app already had - which is the same lesson the
//  partner header taught an hour ago: a private copy of a shared thing looks
//  harmless and then silently stops receiving everything the shared one gets.
//
//  Local-first falls out for free. Every cloud call in `MedicineStore` is gated
//  on `SupabaseRepo.isLoggedIn`, so signed out it is a purely local record and
//  behaves identically. Nothing here needs a backend to work.
//
//  ---------------------------------------------------------------------------
//  What it deliberately does NOT do
//
//  It does not interpret. No dose checking, no interaction warnings, no "you
//  missed one" scolding, and no inference from a drug name to a diagnosis -
//  seeing "Letrozole" does not let us decide she has PCOS. We hold what she
//  tells us and we remind her when she asks to be reminded. Her clinician owns
//  everything else, and `TruthSource.verifiedMedication` sits above our own
//  calculation precisely so a schedule she reports outranks anything we derive.
// =============================================================================

import 'package:flutter/material.dart';

import '../../models/medication.dart';
import '../../services/medicine_store.dart';
import 'ttc_common.dart';
import 'ttc_strings.dart';

void openTtcMedication(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const TtcMedicationScreen(),
    settings: const RouteSettings(name: 'ttc/medication'),
  ));
}

class TtcMedicationScreen extends StatelessWidget {
  const TtcMedicationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([MedicineStore.instance, TtcLang.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final meds = MedicineStore.instance.activeMeds;

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
              children: [
                TtcBackBar(title: t.medTitle),
                const SizedBox(height: 16),

                // A feature is never hidden: the empty state is an invitation,
                // and it says what this is FOR rather than that it is empty.
                if (meds.isEmpty)
                  TtcEmpty(
                    icon: Icons.medication_outlined,
                    title: t.medEmptyTitle,
                    body: t.medEmptyBody,
                    cta: t.medAdd,
                    onTap: () => _edit(context, t, null),
                  )
                else ...[
                  ttcSectionTitle(
                    t.medToday,
                    trailing: GestureDetector(
                      onTap: () => _edit(context, t, null),
                      behavior: HitTestBehavior.opaque,
                      child: Text(t.medAdd,
                          style: ttcBody(12.5,
                              color: ttcPurple, w: FontWeight.w800)),
                    ),
                  ),
                  for (final m in meds) ...[
                    _MedCard(med: m, t: t),
                    const SizedBox(height: 10),
                  ],
                ],

                const SizedBox(height: 18),
                // States what we do and do not do with this, in her words,
                // where she is looking at it.
                TtcCard(
                  color: ttcPanel,
                  child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.info_outline_rounded,
                            size: 17, color: ttcBrown),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(t.medNoAdvice,
                              style: ttcBody(12.5, color: ttcBrown, h: 1.55)),
                        ),
                      ]),
                ),
                const SizedBox(height: 14),
                TtcDisclaimer(t: t),
              ],
            ),
          ),
        );
      },
    );
  }

  static Future<void> _edit(
      BuildContext context, TtcS t, Medication? existing) async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _MedSheet(t: t, existing: existing),
    );
  }
}

// ---- one medication ---------------------------------------------------------

class _MedCard extends StatelessWidget {
  const _MedCard({required this.med, required this.t});

  final Medication med;
  final TtcS t;

  @override
  Widget build(BuildContext context) {
    final taken = MedicineStore.instance.isTakenToday(med.id);
    final times = med.alarms
        .where((a) => a.enabled)
        .expand((a) => a.times)
        .toList()
      ..sort();

    return TtcCard(
      onTap: () => TtcMedicationScreen._edit(context, t, med),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // The tick is the point of the card, so it is the biggest target on
          // it. Never coloured by how many are outstanding.
          GestureDetector(
            onTap: () => MedicineStore.instance.toggleToday(med.id),
            behavior: HitTestBehavior.opaque,
            child: Container(
              width: 30,
              height: 30,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: taken ? ttcPurple : Colors.transparent,
                shape: BoxShape.circle,
                border: Border.all(
                    color: taken ? ttcPurple : ttcLine, width: 1.6),
              ),
              child: taken
                  ? const Icon(Icons.check_rounded,
                      size: 17, color: Colors.white)
                  : null,
            ),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(med.name, style: ttcJakarta(15.5)),
                  if (med.dose.isNotEmpty || med.frequency.isNotEmpty) ...[
                    const SizedBox(height: 3),
                    Text(
                        [med.dose, med.frequency]
                            .where((s) => s.isNotEmpty)
                            .join(' · '),
                        style: ttcBody(12.5)),
                  ],
                ]),
          ),
          const Icon(Icons.chevron_right_rounded, size: 18, color: ttcMuted),
        ]),
        if (times.isNotEmpty) ...[
          const SizedBox(height: 12),
          ttcDivider(),
          const SizedBox(height: 10),
          Row(children: [
            const Icon(Icons.notifications_none_rounded,
                size: 15, color: ttcPurple),
            const SizedBox(width: 8),
            Expanded(
              child: Text(times.map(_fmtTime).join(', '),
                  style: ttcBody(12, color: ttcSoft, w: FontWeight.w600)),
            ),
          ]),
        ],
        if (med.notes.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(med.notes, style: ttcBody(12, h: 1.5)),
        ],
      ]),
    );
  }

  static String _fmtTime(int minutes) {
    final h = minutes ~/ 60;
    final m = minutes % 60;
    final suffix = h < 12 ? 'am' : 'pm';
    final h12 = h % 12 == 0 ? 12 : h % 12;
    return '$h12:${m.toString().padLeft(2, '0')} $suffix';
  }
}

// ---- add / edit -------------------------------------------------------------

class _MedSheet extends StatefulWidget {
  const _MedSheet({required this.t, this.existing});

  final TtcS t;
  final Medication? existing;

  @override
  State<_MedSheet> createState() => _MedSheetState();
}

class _MedSheetState extends State<_MedSheet> {
  late final TextEditingController _name;
  late final TextEditingController _dose;
  late final TextEditingController _freq;
  late final TextEditingController _notes;

  /// Minutes since midnight. Empty means "no reminder", which is a real choice
  /// and the default - a medication she takes at the clinic does not need one.
  late List<int> _times;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _dose = TextEditingController(text: e?.dose ?? '');
    _freq = TextEditingController(text: e?.frequency ?? '');
    _notes = TextEditingController(text: e?.notes ?? '');
    _times = [
      ...?e?.alarms.where((a) => a.enabled).expand((a) => a.times),
    ]..sort();
  }

  @override
  void dispose() {
    _name.dispose();
    _dose.dispose();
    _freq.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    final editing = widget.existing != null;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
      child: Container(
        decoration: const BoxDecoration(
          color: ttcBg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(26)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 20),
        child: SingleChildScrollView(
          child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                          color: ttcLine,
                          borderRadius: BorderRadius.circular(999))),
                ),
                const SizedBox(height: 18),
                Text(editing ? t.medEdit : t.medAdd, style: ttcJakarta(18)),
                const SizedBox(height: 16),

                _field(t.medName, _name, hint: t.medNameHint),
                const SizedBox(height: 12),
                _field(t.medDose, _dose, hint: t.medDoseHint),
                const SizedBox(height: 12),
                _field(t.medFrequency, _freq, hint: t.medFrequencyHint),
                const SizedBox(height: 12),
                _field(t.medNotes, _notes, hint: t.medNotesHint, lines: 3),
                const SizedBox(height: 18),

                // ---- reminders ------------------------------------------
                Text(t.medReminders.toUpperCase(),
                    style: ttcBody(9.5,
                        color: ttcMuted, w: FontWeight.w800)),
                const SizedBox(height: 4),
                Text(t.medRemindersNote, style: ttcBody(12, h: 1.5)),
                const SizedBox(height: 10),
                Wrap(spacing: 8, runSpacing: 8, children: [
                  for (final m in _times)
                    GestureDetector(
                      onTap: () => setState(() => _times.remove(m)),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: ttcPanel,
                          borderRadius: BorderRadius.circular(999),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Text(_MedCard._fmtTime(m),
                              style: ttcBody(12.5,
                                  color: ttcPurple, w: FontWeight.w700)),
                          const SizedBox(width: 6),
                          const Icon(Icons.close_rounded,
                              size: 14, color: ttcPurple),
                        ]),
                      ),
                    ),
                  GestureDetector(
                    onTap: _addTime,
                    behavior: HitTestBehavior.opaque,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: ttcPurple, width: 1.2),
                      ),
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        const Icon(Icons.add_rounded,
                            size: 15, color: ttcPurple),
                        const SizedBox(width: 5),
                        Text(t.medAddTime,
                            style: ttcBody(12.5,
                                color: ttcPurple, w: FontWeight.w700)),
                      ]),
                    ),
                  ),
                ]),
                const SizedBox(height: 22),

                GestureDetector(
                  onTap: _save,
                  behavior: HitTestBehavior.opaque,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(
                        color: ttcPurple,
                        borderRadius: BorderRadius.circular(16)),
                    child: Text(t.medSave,
                        style: ttcBody(14,
                            color: Colors.white, w: FontWeight.w800)),
                  ),
                ),
                if (editing) ...[
                  const SizedBox(height: 10),
                  Center(
                    child: GestureDetector(
                      onTap: _delete,
                      behavior: HitTestBehavior.opaque,
                      child: Padding(
                        padding: const EdgeInsets.all(8),
                        child: Text(t.medDelete,
                            style: ttcBody(12.5,
                                color: ttcMuted, w: FontWeight.w700)),
                      ),
                    ),
                  ),
                ],
              ]),
        ),
      ),
    );
  }

  Widget _field(String label, TextEditingController c,
          {String hint = '', int lines = 1}) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: ttcBody(9.5, color: ttcMuted, w: FontWeight.w800)),
        const SizedBox(height: 6),
        TextField(
          controller: c,
          maxLines: lines,
          style: ttcBody(14, color: ttcInk),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: ttcBody(13.5, color: ttcMuted),
            filled: true,
            fillColor: Colors.white,
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: ttcLine),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: ttcLine),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: ttcPurple, width: 1.4),
            ),
          ),
        ),
      ]);

  Future<void> _addTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: const TimeOfDay(hour: 9, minute: 0),
    );
    if (picked == null) return;
    final m = picked.hour * 60 + picked.minute;
    if (_times.contains(m)) return;
    setState(() => _times = [..._times, m]..sort());
  }

  Future<void> _save() async {
    final name = _name.text.trim();
    if (name.isEmpty) return; // nothing to record
    final nav = Navigator.of(context);
    final store = MedicineStore.instance;
    final existing = widget.existing;

    // One alarm config carrying every chosen time - the model supports several
    // times per config, so a thrice-daily medication is one alarm, not three.
    final alarms = _times.isEmpty
        ? const <MedAlarm>[]
        : [
            MedAlarm(
              id: existing?.alarms.isNotEmpty == true
                  ? existing!.alarms.first.id
                  : 'ttcma_${DateTime.now().microsecondsSinceEpoch}',
              times: _times,
              repeat: MedAlarmRepeat.daily,
            ),
          ];

    if (existing == null) {
      await store.addMed(Medication(
        id: 'ttcm_${DateTime.now().microsecondsSinceEpoch}',
        name: name,
        // `medication`, not `supplement`: this screen exists for the things a
        // clinic prescribed, and the distinction is what the care pathway
        // reasons about.
        type: MedType.medication,
        dose: _dose.text.trim(),
        frequency: _freq.text.trim(),
        notes: _notes.text.trim(),
        startDateIso: DateTime.now().toIso8601String(),
        alarms: alarms,
      ));
    } else {
      await store.updateMed(existing.copyWith(
        name: name,
        dose: _dose.text.trim(),
        frequency: _freq.text.trim(),
        notes: _notes.text.trim(),
        alarms: alarms,
      ));
    }
    nav.pop();
  }

  Future<void> _delete() async {
    final nav = Navigator.of(context);
    await MedicineStore.instance.deleteMed(widget.existing!.id);
    nav.pop();
  }
}

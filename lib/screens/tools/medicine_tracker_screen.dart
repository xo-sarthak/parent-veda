// =============================================================================
//  MedicineTrackerScreen — Daily Medication & Supplement Tracking
// -----------------------------------------------------------------------------
//  A calm "nourishment companion": Today's Nourishment with a gentle
//  mark-as-taken, a weekly awareness view, supplement education, and custom
//  medicines. Never shaming, never gamified — just easy tracking. Warm-Nest UI.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../localization/app_language.dart';
import '../../models/medication.dart';
import '../../services/medicine_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../theme/app_theme.dart';

class MedicineTrackerScreen extends StatefulWidget {
  const MedicineTrackerScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<MedicineTrackerScreen> createState() => _MedicineTrackerScreenState();
}

class _MedicineTrackerScreenState extends State<MedicineTrackerScreen> {
  int _tab = 0; // 0 Daily · 1 Weekly
  PregnancyController get p => widget.controller;

  static const List<BoxShadow> _soft = [
    BoxShadow(color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 3)),
  ];
  static const Color _accent = Color(0xFF4F7A52); // calm green — "nourishment"

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([MedicineStore.instance, p]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final s = S(p.language);
    final store = MedicineStore.instance;
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        title: Text(s.medTitle,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: AppTheme.primary900)),
      ),
      body: store.isEmpty ? _setup(s) : _main(s, store),
      floatingActionButton: store.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _addSheet(s),
              backgroundColor: _accent,
              icon: const Icon(Icons.add_rounded, color: Colors.white),
              label: Text(s.medAddNew,
                  style: GoogleFonts.manrope(
                      fontWeight: FontWeight.w700, color: Colors.white)),
            ),
    );
  }

  // --- setup / empty ---------------------------------------------------------
  Widget _setup(S s) => ListView(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 28),
        children: [
          Container(
            width: 84,
            height: 84,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: _accent.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: const Icon(Icons.medication_liquid_rounded,
                size: 40, color: _accent),
          ),
          const SizedBox(height: 18),
          Text(s.medSetupTitle,
              textAlign: TextAlign.center,
              style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primary900)),
          const SizedBox(height: 8),
          Text(s.medSetupBody,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                  fontSize: 14, height: 1.5, color: AppTheme.neutral600)),
          const SizedBox(height: 22),
          _presetWrap(s),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: () => _medForm(s, null),
            icon: const Icon(Icons.add_rounded, size: 18),
            label: Text(s.medAddCustom),
          ),
          const SizedBox(height: 18),
          _disclaimer(s),
        ],
      );

  Widget _presetWrap(S s) => Wrap(
        spacing: 10,
        runSpacing: 10,
        alignment: WrapAlignment.center,
        children: [
          for (final k in kMedPresetKeys)
            GestureDetector(
              onTap: () => _medForm(s, k),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(99),
                  boxShadow: _soft,
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.add_rounded, size: 16, color: _accent),
                  const SizedBox(width: 6),
                  Text(s.medPresetName(k),
                      style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary800)),
                ]),
              ),
            ),
        ],
      );

  // --- main (daily / weekly) -------------------------------------------------
  Widget _main(S s, MedicineStore store) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 100),
      children: [
        _segmented(s),
        const SizedBox(height: 14),
        if (_tab == 0) ..._daily(s, store) else ..._weekly(s, store),
        const SizedBox(height: 18),
        _disclaimer(s),
      ],
    );
  }

  Widget _segmented(S s) {
    final tabs = [s.medTabDaily, s.medTabWeekly];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: _soft,
      ),
      child: Row(children: [
        for (int i = 0; i < tabs.length; i++)
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => _tab = i),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: _tab == i ? _accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(tabs[i],
                    style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: _tab == i ? Colors.white : AppTheme.neutral600)),
              ),
            ),
          ),
      ]),
    );
  }

  List<Widget> _daily(S s, MedicineStore store) {
    final meds = store.activeMeds;
    final done = store.takenTodayCount;
    final total = store.todayTotal;
    return [
      Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_accent.withValues(alpha: 0.14), AppTheme.surface],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: _soft,
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(s.medTodayNourishment,
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary900)),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: total == 0 ? 0 : done / total,
              minHeight: 8,
              backgroundColor: AppTheme.surfaceContainerHigh,
              valueColor: const AlwaysStoppedAnimation(_accent),
            ),
          ),
          const SizedBox(height: 8),
          Text(s.medProgress(done, total),
              style: GoogleFonts.manrope(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                  color: AppTheme.neutral600)),
        ]),
      ),
      const SizedBox(height: 14),
      for (final m in meds) _dailyItem(s, store, m),
    ];
  }

  Widget _dailyItem(S s, MedicineStore store, Medication m) {
    final taken = store.isTakenToday(m.id);
    final sub = [m.dose, m.time].where((x) => x.trim().isNotEmpty).join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(18),
        boxShadow: _soft,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _details(s, store, m),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(children: [
              Container(
                width: 42,
                height: 42,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                    color: _accent.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.medication_rounded,
                    color: _accent, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(m.name,
                        style: GoogleFonts.plusJakartaSans(
                            fontSize: 14.5,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.primary900)),
                    if (sub.isNotEmpty)
                      Text(sub,
                          style: GoogleFonts.manrope(
                              fontSize: 12, color: AppTheme.neutral500)),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () {
                  final wasTaken = taken;
                  store.toggleToday(m.id);
                  if (!wasTaken) _snack(s.medLogged(m.name));
                },
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(
                    color: taken ? _accent : _accent.withValues(alpha: 0.10),
                    borderRadius: BorderRadius.circular(99),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(taken ? Icons.check_rounded : Icons.circle_outlined,
                        size: 16, color: taken ? Colors.white : _accent),
                    const SizedBox(width: 6),
                    Text(taken ? s.medTakenDone : s.medTaken,
                        style: GoogleFonts.manrope(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                            color: taken ? Colors.white : _accent)),
                  ]),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }

  List<Widget> _weekly(S s, MedicineStore store) {
    final meds = store.activeMeds;
    return [
      Text(s.medWeekOverview,
          style: GoogleFonts.plusJakartaSans(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: AppTheme.primary900)),
      const SizedBox(height: 10),
      for (final m in meds)
        Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(18),
            boxShadow: _soft,
          ),
          child: Row(children: [
            Expanded(
              child: Text(m.name,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
            ),
            Text(s.medDaysOf7(store.weeklyDays(m.id)),
                style: GoogleFonts.manrope(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: _accent)),
          ]),
        ),
      const SizedBox(height: 8),
      Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _accent.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(18),
        ),
        child: Text(s.medConsistency(store.consistencyDays30),
            style: GoogleFonts.manrope(
                fontSize: 13, height: 1.5, color: AppTheme.primary800)),
      ),
    ];
  }

  Widget _disclaimer(S s) => Row(children: [
        const Icon(Icons.info_outline_rounded,
            size: 15, color: AppTheme.neutral400),
        const SizedBox(width: 8),
        Expanded(
          child: Text(s.medDisclaimer,
              style: GoogleFonts.manrope(
                  fontSize: 11.5, color: AppTheme.neutral500)),
        ),
      ]);

  // --- add / form ------------------------------------------------------------
  void _addSheet(S s) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 16),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.neutral300,
                        borderRadius: BorderRadius.circular(99))),
              ),
              const SizedBox(height: 16),
              Text(s.medSetupBody,
                  style: GoogleFonts.manrope(
                      fontSize: 13, color: AppTheme.neutral600)),
              const SizedBox(height: 12),
              _presetWrap(s),
              const SizedBox(height: 14),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(ctx);
                    _medForm(s, null);
                  },
                  icon: const Icon(Icons.add_rounded, size: 18),
                  label: Text(s.medAddCustom),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _medForm(S s, String? presetKey) {
    final nameCtrl = TextEditingController(
        text: presetKey != null ? s.medPresetName(presetKey) : '');
    final doseCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final freqCtrl = TextEditingController();
    final notesCtrl = TextEditingController();

    Widget field(String hint, TextEditingController c, {int max = 1}) => Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TextField(
            controller: c,
            minLines: 1,
            maxLines: max,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppTheme.surfaceContainer,
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: BorderSide.none),
            ),
          ),
        );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
        child: Container(
          decoration: const BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
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
                          color: AppTheme.neutral300,
                          borderRadius: BorderRadius.circular(99))),
                ),
                const SizedBox(height: 16),
                Text(s.medAddTitle,
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary900)),
                const SizedBox(height: 14),
                field(s.medName, nameCtrl),
                field(s.medDose, doseCtrl),
                field(s.medTime, timeCtrl),
                field(s.medFrequency, freqCtrl),
                field(s.medNotes, notesCtrl, max: 3),
                const SizedBox(height: 6),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    style: FilledButton.styleFrom(backgroundColor: _accent),
                    onPressed: () {
                      final name = nameCtrl.text.trim();
                      if (name.isEmpty) {
                        Navigator.pop(ctx);
                        return;
                      }
                      MedicineStore.instance.addMed(Medication(
                        id: 'med_${DateTime.now().microsecondsSinceEpoch}',
                        name: name,
                        type: presetKey != null
                            ? MedType.supplement
                            : MedType.custom,
                        dose: doseCtrl.text.trim(),
                        time: timeCtrl.text.trim(),
                        frequency: freqCtrl.text.trim(),
                        notes: notesCtrl.text.trim(),
                        presetKey: presetKey,
                        startDateIso: DateTime.now().toIso8601String(),
                      ));
                      Navigator.pop(ctx);
                    },
                    child: Text(s.saveCta),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _details(S s, MedicineStore store, Medication m) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 12),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                        color: AppTheme.neutral300,
                        borderRadius: BorderRadius.circular(99))),
              ),
              const SizedBox(height: 16),
              Text(m.name,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
              if ([m.dose, m.time, m.frequency]
                  .any((x) => x.trim().isNotEmpty)) ...[
                const SizedBox(height: 4),
                Text(
                    [m.dose, m.time, m.frequency]
                        .where((x) => x.trim().isNotEmpty)
                        .join(' · '),
                    style: GoogleFonts.manrope(
                        fontSize: 12.5, color: AppTheme.neutral500)),
              ],
              if (m.presetKey != null) ...[
                const SizedBox(height: 12),
                Text(s.medPresetInfo(m.presetKey!),
                    style: GoogleFonts.manrope(
                        fontSize: 13.5,
                        height: 1.5,
                        color: AppTheme.neutral700)),
              ],
              if (m.notes.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Text(m.notes,
                    style: GoogleFonts.manrope(
                        fontSize: 13, height: 1.5, color: AppTheme.neutral600)),
              ],
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.pop(ctx);
                  _confirmDelete(s, store, m);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(children: [
                    const Icon(Icons.delete_outline_rounded,
                        size: 20, color: AppTheme.danger),
                    const SizedBox(width: 12),
                    Text(s.delete,
                        style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.danger)),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _confirmDelete(S s, MedicineStore store, Medication m) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(s.medDeleteQ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: Text(s.cancel)),
          TextButton(
            onPressed: () {
              store.deleteMed(m.id);
              Navigator.pop(ctx);
            },
            child: Text(s.delete,
                style: const TextStyle(color: AppTheme.danger)),
          ),
        ],
      ),
    );
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}

// =============================================================================
//  MedicineTrackerScreen - Daily Medication & Supplement Tracking
// -----------------------------------------------------------------------------
//  A calm "nourishment companion": Today's Nourishment with a gentle
//  mark-as-taken, a weekly awareness view, supplement education, and custom
//  medicines. Never shaming, never gamified - just easy tracking. Warm-Nest UI.
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
  static const Color _accent = Color(0xFF4F7A52); // calm green - "nourishment"

  // Weekday short labels, index 0..6 == Dart weekday 1..7 (Mon..Sun).
  static const List<String> _wdShort = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
  static const List<String> _wdFull = [
    'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun',
  ];

  // minutes-since-midnight -> "9:00 AM"
  static String _fmtMinutes(int mins) {
    final h = mins ~/ 60, m = mins % 60;
    final ap = h < 12 ? 'AM' : 'PM';
    var hh = h % 12;
    if (hh == 0) hh = 12;
    return '$hh:${m.toString().padLeft(2, '0')} $ap';
  }

  static String _fmtDate(String? iso) {
    if (iso == null || iso.isEmpty) return '';
    final d = DateTime.tryParse(iso);
    if (d == null) return '';
    return '${d.day} ${_wdMonth[d.month - 1]} ${d.year}';
  }

  static const List<String> _wdMonth = [
    'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
    'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
  ];

  // "9:00 AM, 6:00 PM · Daily"  /  "8:00 AM · M W F"
  static String _alarmSummary(MedAlarm a) {
    final times = (a.times.toList()..sort()).map(_fmtMinutes).join(', ');
    String rec;
    switch (a.repeat) {
      case MedAlarmRepeat.daily:
        rec = 'Daily';
        break;
      case MedAlarmRepeat.weekly:
      case MedAlarmRepeat.custom:
        final wds = a.weekdays.toList()..sort();
        rec = wds.isEmpty
            ? (a.repeat == MedAlarmRepeat.weekly ? 'Weekly' : 'Custom')
            : wds.map((w) => _wdFull[w - 1]).join(' ');
        break;
    }
    return times.isEmpty ? rec : '$times · $rec';
  }

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [
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
                ..._cardAlarms(store, m),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Compact per-alarm rows shown inside a medication card: times + recurrence
  // summary with an enable/disable switch (toggling reschedules immediately).
  List<Widget> _cardAlarms(MedicineStore store, Medication m) {
    if (m.alarms.isEmpty) return const [];
    return [
      const SizedBox(height: 8),
      const Divider(height: 1, color: AppTheme.outlineVariant),
      for (final a in m.alarms)
        Padding(
          padding: const EdgeInsets.only(top: 8),
          child: Row(children: [
            Icon(Icons.alarm_rounded,
                size: 16,
                color: a.enabled ? _accent : AppTheme.neutral400),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                _alarmSummary(a),
                style: GoogleFonts.manrope(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: a.enabled ? AppTheme.primary800 : AppTheme.neutral500,
                ),
              ),
            ),
            SizedBox(
              height: 28,
              child: Switch(
                value: a.enabled,
                activeThumbColor: _accent,
                materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                onChanged: (v) {
                  final updated = m.alarms
                      .map((x) => x.id == a.id ? x.copyWith(enabled: v) : x)
                      .toList();
                  store.updateMed(m.copyWith(alarms: updated));
                },
              ),
            ),
          ]),
        ),
    ];
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

  void _medForm(S s, String? presetKey, {Medication? existing}) {
    final nameCtrl = TextEditingController(
        text: existing?.name ??
            (presetKey != null ? s.medPresetName(presetKey) : ''));
    final doseCtrl = TextEditingController(text: existing?.dose ?? '');
    final timeCtrl = TextEditingController(text: existing?.time ?? '');
    final freqCtrl = TextEditingController(text: existing?.frequency ?? '');
    final notesCtrl = TextEditingController(text: existing?.notes ?? '');
    // Working copy of the alarm list - mutated in place, refreshed via setSheet.
    final alarms = <MedAlarm>[...?existing?.alarms];

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
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
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
                  Text(existing != null ? 'Edit medication' : s.medAddTitle,
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
                  _alarmsSection(
                    alarms,
                    getDefaultTitle: () => nameCtrl.text.trim(),
                    onChanged: () => setSheet(() {}),
                  ),
                  const SizedBox(height: 12),
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
                        if (existing != null) {
                          MedicineStore.instance.updateMed(existing.copyWith(
                            name: name,
                            dose: doseCtrl.text.trim(),
                            time: timeCtrl.text.trim(),
                            frequency: freqCtrl.text.trim(),
                            notes: notesCtrl.text.trim(),
                            alarms: List<MedAlarm>.from(alarms),
                          ));
                        } else {
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
                            alarms: List<MedAlarm>.from(alarms),
                          ));
                        }
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
      ),
    );
  }

  // --- alarm configuration ---------------------------------------------------

  // The "Alarms" block inside the med form: header, each configured alarm as an
  // editable/removable tile, and an "Add alarm" button.
  Widget _alarmsSection(
    List<MedAlarm> alarms, {
    required String Function() getDefaultTitle,
    required VoidCallback onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(children: [
          const Icon(Icons.alarm_rounded, size: 18, color: _accent),
          const SizedBox(width: 8),
          Text('Alarms',
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                  color: AppTheme.primary900)),
        ]),
        const SizedBox(height: 8),
        for (int i = 0; i < alarms.length; i++)
          Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.surfaceContainer,
              borderRadius: BorderRadius.circular(14),
            ),
            child: Row(children: [
              Icon(Icons.alarm_rounded,
                  size: 16,
                  color:
                      alarms[i].enabled ? _accent : AppTheme.neutral400),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alarms[i].title.trim().isNotEmpty
                          ? alarms[i].title.trim()
                          : getDefaultTitle().isNotEmpty
                              ? getDefaultTitle()
                              : 'Alarm',
                      style: GoogleFonts.manrope(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary800),
                    ),
                    Text(_alarmSummary(alarms[i]),
                        style: GoogleFonts.manrope(
                            fontSize: 11.5, color: AppTheme.neutral500)),
                  ],
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.edit_outlined,
                    size: 18, color: AppTheme.neutral500),
                onPressed: () => _alarmSheet(
                  alarms[i],
                  getDefaultTitle(),
                  (edited) {
                    alarms[i] = edited;
                    onChanged();
                  },
                ),
              ),
              IconButton(
                visualDensity: VisualDensity.compact,
                icon: const Icon(Icons.close_rounded,
                    size: 18, color: AppTheme.neutral500),
                onPressed: () {
                  alarms.removeAt(i);
                  onChanged();
                },
              ),
            ]),
          ),
        Align(
          alignment: Alignment.centerLeft,
          child: OutlinedButton.icon(
            onPressed: () => _alarmSheet(
              null,
              getDefaultTitle(),
              (created) {
                alarms.add(created);
                onChanged();
              },
            ),
            icon: const Icon(Icons.add_alarm_rounded, size: 18),
            label: const Text('Add alarm'),
          ),
        ),
      ],
    );
  }

  // Full editor for a single MedAlarm: title, multiple times, recurrence
  // (Daily / Weekly / Custom), weekday picker, start/end date, enable toggle.
  void _alarmSheet(
    MedAlarm? existing,
    String defaultTitle,
    ValueChanged<MedAlarm> onSave,
  ) {
    final titleCtrl =
        TextEditingController(text: existing?.title ?? '');
    final times = <int>[...?existing?.times];
    if (times.isEmpty) times.add(9 * 60); // sensible default 9:00 AM
    var repeat = existing?.repeat ?? MedAlarmRepeat.daily;
    final weekdays = <int>{...?existing?.weekdays};
    String? startIso = existing?.startDateIso;
    String? endIso = existing?.endDateIso;
    var enabled = existing?.enabled ?? true;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
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
                  Text(existing != null ? 'Edit alarm' : 'New alarm',
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary900)),
                  const SizedBox(height: 14),
                  // Title
                  TextField(
                    controller: titleCtrl,
                    decoration: InputDecoration(
                      labelText: 'Alarm title',
                      hintText: defaultTitle.isNotEmpty
                          ? defaultTitle
                          : 'e.g. Iron tablet',
                      filled: true,
                      fillColor: AppTheme.surfaceContainer,
                      border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Times
                  _alarmLabel('Times'),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (int i = 0; i < times.length; i++)
                        InputChip(
                          label: Text(_fmtMinutes(times[i])),
                          onDeleted: times.length == 1
                              ? null
                              : () => setSheet(() => times.removeAt(i)),
                          backgroundColor:
                              _accent.withValues(alpha: 0.10),
                          labelStyle: GoogleFonts.manrope(
                              fontWeight: FontWeight.w700, color: _accent),
                        ),
                      ActionChip(
                        avatar: const Icon(Icons.add_rounded,
                            size: 16, color: _accent),
                        label: const Text('Add time'),
                        onPressed: () async {
                          final picked = await showTimePicker(
                            context: ctx,
                            initialTime: const TimeOfDay(hour: 9, minute: 0),
                          );
                          if (picked != null) {
                            final mins = picked.hour * 60 + picked.minute;
                            if (!times.contains(mins)) {
                              setSheet(() => times.add(mins));
                            }
                          }
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  // Recurrence
                  _alarmLabel('Repeat'),
                  const SizedBox(height: 8),
                  _repeatSegmented(repeat, (r) => setSheet(() => repeat = r)),
                  if (repeat != MedAlarmRepeat.daily) ...[
                    const SizedBox(height: 12),
                    _weekdayPicker(weekdays, () => setSheet(() {})),
                  ],
                  const SizedBox(height: 16),
                  // Dates
                  _alarmLabel('Schedule window'),
                  const SizedBox(height: 8),
                  _dateRow(
                    'Start date',
                    startIso,
                    onPick: (iso) => setSheet(() => startIso = iso),
                    onClear: () => setSheet(() => startIso = null),
                  ),
                  const SizedBox(height: 8),
                  _dateRow(
                    'End date',
                    endIso,
                    onPick: (iso) => setSheet(() => endIso = iso),
                    onClear: () => setSheet(() => endIso = null),
                  ),
                  const SizedBox(height: 8),
                  // Enable toggle
                  Row(children: [
                    Expanded(
                      child: Text('Alarm enabled',
                          style: GoogleFonts.manrope(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.primary800)),
                    ),
                    Switch(
                      value: enabled,
                      activeThumbColor: _accent,
                      onChanged: (v) => setSheet(() => enabled = v),
                    ),
                  ]),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: _accent),
                      onPressed: times.isEmpty
                          ? null
                          : () {
                              onSave(MedAlarm(
                                id: existing?.id ??
                                    'alm_${DateTime.now().microsecondsSinceEpoch}',
                                title: titleCtrl.text.trim(),
                                times: List<int>.from(times)..sort(),
                                repeat: repeat,
                                weekdays: repeat == MedAlarmRepeat.daily
                                    ? const []
                                    : (weekdays.toList()..sort()),
                                startDateIso: startIso,
                                endDateIso: endIso,
                                enabled: enabled,
                              ));
                              Navigator.pop(ctx);
                            },
                      child: const Text('Save alarm'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _alarmLabel(String text) => Text(text,
      style: GoogleFonts.manrope(
          fontSize: 12.5,
          fontWeight: FontWeight.w700,
          color: AppTheme.neutral600));

  Widget _repeatSegmented(
      MedAlarmRepeat current, ValueChanged<MedAlarmRepeat> onPick) {
    const opts = [
      MedAlarmRepeat.daily,
      MedAlarmRepeat.weekly,
      MedAlarmRepeat.custom,
    ];
    const labels = ['Daily', 'Weekly', 'Custom'];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppTheme.surfaceContainer,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(children: [
        for (int i = 0; i < opts.length; i++)
          Expanded(
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => onPick(opts[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 9),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: current == opts[i] ? _accent : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(labels[i],
                    style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: current == opts[i]
                            ? Colors.white
                            : AppTheme.neutral600)),
              ),
            ),
          ),
      ]),
    );
  }

  Widget _weekdayPicker(Set<int> selected, VoidCallback onChanged) => Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          for (int wd = 1; wd <= 7; wd++)
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
                if (selected.contains(wd)) {
                  selected.remove(wd);
                } else {
                  selected.add(wd);
                }
                onChanged();
              },
              child: Container(
                width: 36,
                height: 36,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: selected.contains(wd)
                      ? _accent
                      : AppTheme.surfaceContainer,
                  shape: BoxShape.circle,
                ),
                child: Text(_wdShort[wd - 1],
                    style: GoogleFonts.manrope(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: selected.contains(wd)
                            ? Colors.white
                            : AppTheme.neutral600)),
              ),
            ),
        ],
      );

  Widget _dateRow(
    String label,
    String? iso, {
    required ValueChanged<String> onPick,
    required VoidCallback onClear,
  }) {
    final has = iso != null && iso.isNotEmpty;
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: () async {
        final now = DateTime.now();
        final init = has ? (DateTime.tryParse(iso) ?? now) : now;
        final picked = await showDatePicker(
          context: context,
          initialDate: init,
          firstDate: DateTime(now.year - 1),
          lastDate: DateTime(now.year + 3),
        );
        if (picked != null) onPick(picked.toIso8601String());
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.surfaceContainer,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(children: [
          const Icon(Icons.event_rounded,
              size: 18, color: AppTheme.neutral500),
          const SizedBox(width: 10),
          Expanded(
            child: Text(label,
                style: GoogleFonts.manrope(
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.primary800)),
          ),
          Text(has ? _fmtDate(iso) : 'Not set',
              style: GoogleFonts.manrope(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: has ? _accent : AppTheme.neutral400)),
          if (has)
            GestureDetector(
              onTap: onClear,
              child: const Padding(
                padding: EdgeInsets.only(left: 8),
                child: Icon(Icons.close_rounded,
                    size: 16, color: AppTheme.neutral400),
              ),
            ),
        ]),
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
              if (m.alarms.isNotEmpty) ...[
                const SizedBox(height: 14),
                for (final a in m.alarms)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(children: [
                      Icon(Icons.alarm_rounded,
                          size: 16,
                          color:
                              a.enabled ? _accent : AppTheme.neutral400),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(_alarmSummary(a),
                            style: GoogleFonts.manrope(
                                fontSize: 12.5,
                                color: a.enabled
                                    ? AppTheme.primary800
                                    : AppTheme.neutral500)),
                      ),
                    ]),
                  ),
              ],
              const SizedBox(height: 14),
              InkWell(
                borderRadius: BorderRadius.circular(12),
                onTap: () {
                  Navigator.pop(ctx);
                  _medForm(s, m.presetKey, existing: m);
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(children: [
                    const Icon(Icons.edit_outlined,
                        size: 20, color: _accent),
                    const SizedBox(width: 12),
                    Text('Edit',
                        style: GoogleFonts.manrope(
                            fontSize: 14,
                            fontWeight: FontWeight.w700,
                            color: _accent)),
                  ]),
                ),
              ),
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

// =============================================================================
//  ScansAppointmentsScreen — "Scans & Appointments" care roadmap
// -----------------------------------------------------------------------------
//  Calm, confidence-building roadmap (not hospital software): Upcoming /
//  Completed / Care Roadmap. Scan content is reused from kJourneyMilestones
//  (medical). Mark a scan completed → a Journal "Scans" entry; add an
//  appointment → it appears in the Calendar's "Appointment" lane.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/journey_milestones.dart';
import '../../data/scan_guide_data.dart';
import '../../localization/app_language.dart';
import '../../models/journey_node.dart';
import '../../models/scan_appointment.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/scans_store.dart';
import '../../theme/app_theme.dart';

const Color _scanColor = Color(0xFF2E9C8E); // teal — matches Journal "Scans"
const List<BoxShadow> _soft = [
  BoxShadow(color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 3)),
];

List<JourneyMilestone> _allScans() {
  final list = kJourneyMilestones
      .where((m) => m.type == JourneyNodeType.medical)
      .toList()
    ..sort((a, b) => a.anchorWeek.compareTo(b.anchorWeek));
  return list;
}

class ScansAppointmentsScreen extends StatefulWidget {
  const ScansAppointmentsScreen({super.key, required this.controller});
  final PregnancyController controller;

  @override
  State<ScansAppointmentsScreen> createState() =>
      _ScansAppointmentsScreenState();
}

class _ScansAppointmentsScreenState extends State<ScansAppointmentsScreen> {
  int _tab = 0; // 0 Upcoming · 1 Completed · 2 Roadmap
  PregnancyController get p => widget.controller;

  DateTime _scanDate(JourneyMilestone m) =>
      p.dueDate.subtract(Duration(days: 280 - m.anchorWeek * 7));

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ScansStore.instance, p]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final s = S(p.language);
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        title: Text(s.scnTitle,
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: AppTheme.primary900)),
        actions: [
          IconButton(
            tooltip: s.scnAddAppt,
            icon: const Icon(Icons.add_circle_outline_rounded),
            onPressed: () => _addAppt(s),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 28),
        children: [
          _segmented(s),
          const SizedBox(height: 14),
          if (_tab == 0) ..._upcoming(s) else ..._completed(s),
        ],
      ),
    );
  }

  Widget _segmented(S s) {
    // Care roadmap removed — Roadmap tab dropped. _roadmap/_roadmapRow kept
    // (ignore: unused_element) for revert.
    final tabs = [s.scnTabUpcoming, s.scnTabCompleted];
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
                  color: _tab == i ? _scanColor : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(tabs[i],
                    textAlign: TextAlign.center,
                    style: GoogleFonts.manrope(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: _tab == i ? Colors.white : AppTheme.neutral600)),
              ),
            ),
          ),
      ]),
    );
  }

  // --- Upcoming --------------------------------------------------------------
  List<Widget> _upcoming(S s) {
    final lang = p.language;
    final cw = p.currentWeek;
    final upcomingScans = _allScans()
        .where((m) => !ScansStore.instance.isCompleted(m.id) && m.anchorWeek >= cw - 1)
        .toList();
    final appts = ScansStore.instance.appointments
        .where((a) => !a.date.isBefore(DateTime.now().subtract(const Duration(days: 1))))
        .toList();

    final out = <Widget>[];
    if (upcomingScans.isEmpty && appts.isEmpty) {
      out.add(_note(s.scnUpToDate));
      return out;
    }
    if (upcomingScans.isNotEmpty) {
      out.add(_nextUpHero(s, lang, upcomingScans.first));
      out.add(const SizedBox(height: 14));
      for (final m in upcomingScans.skip(1)) {
        out.add(_scanRow(s, lang, m));
      }
    }
    if (appts.isNotEmpty) {
      out.add(const SizedBox(height: 8));
      out.add(_sectionTitle(s.scnAppts));
      out.add(const SizedBox(height: 8));
      for (final a in appts) {
        out.add(_apptRow(s, a));
      }
    }
    return out;
  }

  Widget _nextUpHero(S s, AppLanguage lang, JourneyMilestone m) {
    final n = _scanDate(m).difference(DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .inDays;
    final why = m.sections.isNotEmpty ? m.sections.first.body.of(lang) : '';
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [_scanColor.withValues(alpha: 0.14), AppTheme.surface],
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: _soft,
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.scnNextUp,
            style: GoogleFonts.manrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: _scanColor)),
        const SizedBox(height: 6),
        Text('${m.emoji} ${m.title.of(lang)}',
            style: GoogleFonts.fraunces(
                fontSize: 22,
                fontWeight: FontWeight.w500,
                color: AppTheme.primary900)),
        const SizedBox(height: 2),
        Text(
            '${m.rangeLabel?.of(lang) ?? s.jrWeekLabel(m.anchorWeek)} · ${s.calInDays(n < 0 ? 0 : n)}',
            style: GoogleFonts.manrope(
                fontSize: 12.5,
                fontWeight: FontWeight.w600,
                color: AppTheme.neutral600)),
        if (why.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(why,
              style: GoogleFonts.manrope(
                  fontSize: 13.5, height: 1.5, color: AppTheme.neutral700)),
        ],
        const SizedBox(height: 14),
        Row(children: [
          Expanded(
            child: FilledButton(
              style: FilledButton.styleFrom(backgroundColor: _scanColor),
              onPressed: () => _openScan(s, m),
              child: Text(s.scnLearnMore),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            onPressed: () => _markDone(s, m),
            child: Text(s.scnMarkDone),
          ),
        ]),
      ]),
    );
  }

  Widget _scanRow(S s, AppLanguage lang, JourneyMilestone m) {
    final completed = ScansStore.instance.isCompleted(m.id);
    return GestureDetector(
      onTap: () => _openScan(s, m),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _soft,
        ),
        child: Row(children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: _scanColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12)),
            child: completed
                ? const Icon(Icons.check_rounded, color: _scanColor, size: 20)
                : const Icon(Icons.medical_services_rounded,
                    color: _scanColor, size: 19),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(m.title.of(lang),
                    style: GoogleFonts.plusJakartaSans(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w700,
                        color: AppTheme.primary900)),
                Text(m.rangeLabel?.of(lang) ?? s.jrWeekLabel(m.anchorWeek),
                    style: GoogleFonts.manrope(
                        fontSize: 12, color: AppTheme.neutral500)),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, color: AppTheme.neutral400),
        ]),
      ),
    );
  }

  // --- Completed -------------------------------------------------------------
  List<Widget> _completed(S s) {
    final lang = p.language;
    final scans = _allScans()
        .where((m) => ScansStore.instance.isCompleted(m.id))
        .toList();
    final doneAppts = ScansStore.instance.appointments
        .where((a) => a.date.isBefore(DateTime.now()))
        .toList();
    if (scans.isEmpty && doneAppts.isEmpty) return [_note(s.scnNoCompleted)];
    final out = <Widget>[];
    for (final m in scans) {
      final c = ScansStore.instance.completedOf(m.id);
      final d = DateTime.tryParse(c?.dateIso ?? '');
      out.add(Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
            color: AppTheme.surface,
            borderRadius: BorderRadius.circular(16),
            boxShadow: _soft),
        child: Row(children: [
          const Icon(Icons.check_circle_rounded, color: _scanColor, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(m.title.of(lang),
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.primary900)),
          ),
          if (d != null)
            Text(s.formatShortDate(d),
                style: GoogleFonts.manrope(
                    fontSize: 11.5, color: AppTheme.neutral500)),
        ]),
      ));
    }
    return out;
  }

  // --- Roadmap (removed from the UI; kept for revert) ------------------------
  // ignore: unused_element
  List<Widget> _roadmap(S s) {
    final lang = p.language;
    final cw = p.currentWeek;
    final scans = _allScans();
    final out = <Widget>[];
    for (final m in scans) {
      final completed = ScansStore.instance.isCompleted(m.id);
      final isCurrent = !completed && m.anchorWeek == cw;
      out.add(_roadmapRow(
        s,
        title: m.title.of(lang),
        sub: m.rangeLabel?.of(lang) ?? s.jrWeekLabel(m.anchorWeek),
        completed: completed,
        current: isCurrent,
        onTap: () => _openScan(s, m),
      ));
    }
    // Delivery at the end of the roadmap.
    out.add(_roadmapRow(s,
        title: s.scnDelivery, sub: s.jrWeekLabel(40), completed: false, current: false));
    return out;
  }

  Widget _roadmapRow(S s,
      {required String title,
      required String sub,
      required bool completed,
      required bool current,
      VoidCallback? onTap}) {
    final dot = completed
        ? _scanColor
        : (current ? AppTheme.primary500 : AppTheme.neutral300);
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(
              color: completed ? _scanColor : (current ? AppTheme.primary500 : AppTheme.surface),
              shape: BoxShape.circle,
              border: Border.all(color: dot, width: 2),
            ),
            child: completed
                ? const Icon(Icons.check_rounded, size: 11, color: Colors.white)
                : null,
          ),
          Expanded(child: Container(width: 2, color: AppTheme.outlineVariant)),
        ]),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: GestureDetector(
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(13),
                decoration: BoxDecoration(
                  color: current
                      ? AppTheme.primary500.withValues(alpha: 0.06)
                      : AppTheme.surface,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: _soft,
                ),
                child: Row(children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(title,
                            style: GoogleFonts.plusJakartaSans(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.primary900)),
                        Text(sub,
                            style: GoogleFonts.manrope(
                                fontSize: 11.5, color: AppTheme.neutral500)),
                      ],
                    ),
                  ),
                  if (current)
                    Text(s.youAreHere,
                        style: GoogleFonts.manrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.primary500)),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // --- helpers ---------------------------------------------------------------
  Widget _sectionTitle(String t) => Text(t,
      style: GoogleFonts.plusJakartaSans(
          fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.primary900));

  Widget _apptRow(S s, Appointment a) {
    final sub = [a.time, a.location, a.doctor]
        .where((x) => x.trim().isNotEmpty)
        .join(' · ');
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(16),
          boxShadow: _soft),
      child: Row(children: [
        Container(
          width: 40,
          height: 40,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: const Color(0xFF4F7A52).withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12)),
          child: const Icon(Icons.event_available_rounded,
              color: Color(0xFF4F7A52), size: 19),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.title,
                  style: GoogleFonts.plusJakartaSans(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: AppTheme.primary900)),
              Text('${s.formatShortDate(a.date)}${sub.isNotEmpty ? ' · $sub' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: GoogleFonts.manrope(
                      fontSize: 12, color: AppTheme.neutral500)),
            ],
          ),
        ),
        IconButton(
          icon: const Icon(Icons.close_rounded,
              size: 18, color: AppTheme.neutral400),
          onPressed: () => ScansStore.instance.deleteAppointment(a.id),
        ),
      ]),
    );
  }

  Widget _note(String msg) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 40, 20, 20),
        child: Center(
          child: Text(msg,
              textAlign: TextAlign.center,
              style: GoogleFonts.manrope(
                  fontSize: 13.5, height: 1.5, color: AppTheme.neutral500)),
        ),
      );

  void _markDone(S s, JourneyMilestone m) {
    ScansStore.instance.markCompleted(
      scanId: m.id,
      journalTitle: s.scnCompletedJournal(m.title.of(p.language)),
      week: m.anchorWeek,
    );
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(s.scnMarkedDone)));
  }

  void _openScan(S s, JourneyMilestone m) {
    Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => _ScanDetail(milestone: m, controller: p)));
  }

  Future<void> _addAppt(S s) async {
    final titleCtrl = TextEditingController();
    final timeCtrl = TextEditingController();
    final locCtrl = TextEditingController();
    final docCtrl = TextEditingController();
    final notesCtrl = TextEditingController();
    var type = ApptType.doctor;
    var date = DateTime.now();

    String typeLabel(ApptType t) => switch (t) {
          ApptType.doctor => s.scnTypeDoctor,
          ApptType.scan => s.scnTypeScan,
          ApptType.test => s.scnTypeTest,
          ApptType.vaccination => s.scnTypeVaccination,
          ApptType.custom => s.scnTypeCustom,
        };

    await showModalBottomSheet(
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
                  Text(s.scnAddAppt,
                      style: GoogleFonts.plusJakartaSans(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.primary900)),
                  const SizedBox(height: 12),
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final t in ApptType.values)
                      GestureDetector(
                        onTap: () => setSheet(() => type = t),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: type == t
                                ? _scanColor
                                : AppTheme.surfaceContainer,
                            borderRadius: BorderRadius.circular(99),
                          ),
                          child: Text(typeLabel(t),
                              style: GoogleFonts.manrope(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w700,
                                  color: type == t
                                      ? Colors.white
                                      : AppTheme.neutral700)),
                        ),
                      ),
                  ]),
                  const SizedBox(height: 12),
                  _field(s.scnApptTitle, titleCtrl),
                  InkWell(
                    borderRadius: BorderRadius.circular(14),
                    onTap: () async {
                      final picked = await showDatePicker(
                        context: ctx,
                        initialDate: date,
                        firstDate: DateTime(date.year - 1),
                        lastDate: DateTime(date.year + 2),
                      );
                      if (picked != null) setSheet(() => date = picked);
                    },
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                          color: AppTheme.surfaceContainer,
                          borderRadius: BorderRadius.circular(14)),
                      child: Row(children: [
                        const Icon(Icons.calendar_today_rounded,
                            size: 18, color: _scanColor),
                        const SizedBox(width: 12),
                        Text(s.formatLongDate(date),
                            style: GoogleFonts.manrope(
                                fontSize: 13.5, color: AppTheme.primary900)),
                      ]),
                    ),
                  ),
                  _field(s.scnApptTime, timeCtrl),
                  _field(s.scnApptLocation, locCtrl),
                  _field(s.scnApptDoctor, docCtrl),
                  _field(s.medNotes, notesCtrl, max: 2),
                  const SizedBox(height: 6),
                  SizedBox(
                    width: double.infinity,
                    child: FilledButton(
                      style: FilledButton.styleFrom(backgroundColor: _scanColor),
                      onPressed: () {
                        final t = titleCtrl.text.trim();
                        if (t.isEmpty) {
                          Navigator.pop(ctx);
                          return;
                        }
                        ScansStore.instance.addAppointment(Appointment(
                          id: 'ap_${DateTime.now().microsecondsSinceEpoch}',
                          title: t,
                          dateIso: date.toIso8601String(),
                          time: timeCtrl.text.trim(),
                          location: locCtrl.text.trim(),
                          doctor: docCtrl.text.trim(),
                          type: type,
                          notes: notesCtrl.text.trim(),
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
      ),
    );
  }

  Widget _field(String hint, TextEditingController c, {int max = 1}) => Padding(
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
}

// =============================================================================
//  Scan detail
// =============================================================================
class _ScanDetail extends StatelessWidget {
  const _ScanDetail({required this.milestone, required this.controller});
  final JourneyMilestone milestone;
  final PregnancyController controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([ScansStore.instance, controller]),
      builder: (context, _) => _build(context),
    );
  }

  Widget _build(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    final m = milestone;
    final completed = ScansStore.instance.isCompleted(m.id);
    final guide = kScanGuides[m.id];

    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: AppTheme.surfaceContainer,
        title: Text(m.title.of(lang),
            style: GoogleFonts.plusJakartaSans(
                fontWeight: FontWeight.w700, color: AppTheme.primary900)),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 28),
        children: [
          Row(children: [
            Container(
              width: 46,
              height: 46,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: _scanColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(13)),
              child: const Icon(Icons.medical_services_rounded,
                  color: _scanColor, size: 22),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text('${m.emoji} ${m.title.of(lang)}',
                  style: GoogleFonts.fraunces(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: AppTheme.primary900)),
            ),
          ]),
          const SizedBox(height: 18),
          // "What is this scan?" — a plain-language intro at the very top.
          if (guide != null) ...[
            _whatIsCard(s, guide.whatIs.of(lang)),
            const SizedBox(height: 18),
          ],
          for (final sec in m.sections)
            if (sec.body.of(lang).trim().isNotEmpty)
              _block(sec.label.of(lang), sec.body.of(lang)),
          for (final b in m.bullets) _bulletBlock(b.label.of(lang), b, lang),
          // Important note.
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
                color: AppTheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(14)),
            child: Text(s.scnImportantNote,
                style: GoogleFonts.manrope(
                    fontSize: 12.5, height: 1.5, color: AppTheme.neutral700)),
          ),
          const SizedBox(height: 18),
          // "How to interpret the report" → full-screen guide (with disclaimer).
          if (guide != null && guide.interpret.isNotEmpty) ...[
            _interpretCta(context, s, m, guide, lang),
            const SizedBox(height: 14),
          ],
          SizedBox(
            width: double.infinity,
            child: completed
                ? OutlinedButton.icon(
                    onPressed: () =>
                        ScansStore.instance.unmarkCompleted(m.id),
                    icon: const Icon(Icons.check_circle_rounded,
                        size: 18, color: _scanColor),
                    label: Text(s.scnMarkedDone),
                  )
                : FilledButton.icon(
                    style: FilledButton.styleFrom(backgroundColor: _scanColor),
                    onPressed: () {
                      ScansStore.instance.markCompleted(
                        scanId: m.id,
                        journalTitle:
                            s.scnCompletedJournal(m.title.of(lang)),
                        week: m.anchorWeek,
                      );
                    },
                    icon: const Icon(Icons.check_rounded, size: 18),
                    label: Text(s.scnMarkDone),
                  ),
          ),
        ],
      ),
    );
  }

  Widget _block(String label, String body) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          if (label.trim().isNotEmpty) ...[
            Text(label,
                style: GoogleFonts.manrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.3,
                    color: _scanColor)),
            const SizedBox(height: 4),
          ],
          Text(body,
              style: GoogleFonts.manrope(
                  fontSize: 14, height: 1.5, color: AppTheme.neutral700)),
        ]),
      );

  Widget _bulletBlock(String label, BulletBlock b, AppLanguage lang) => Padding(
        padding: const EdgeInsets.only(bottom: 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label,
              style: GoogleFonts.manrope(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.3,
                  color: _scanColor)),
          const SizedBox(height: 6),
          for (final item in b.items)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Padding(
                  padding: EdgeInsets.only(top: 6, right: 8),
                  child: Icon(Icons.circle, size: 5, color: _scanColor),
                ),
                Expanded(
                  child: Text(item.of(lang),
                      style: GoogleFonts.manrope(
                          fontSize: 14, height: 1.5, color: AppTheme.neutral700)),
                ),
              ]),
            ),
        ]),
      );

  // "What is this scan?" intro card (shown at the very top).
  Widget _whatIsCard(S s, String body) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: _scanColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _scanColor.withValues(alpha: 0.16)),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.info_outline_rounded, size: 18, color: _scanColor),
            const SizedBox(width: 8),
            Text(s.scnWhatIs,
                style: GoogleFonts.plusJakartaSans(
                    fontSize: 14.5,
                    fontWeight: FontWeight.w800,
                    color: _scanColor)),
          ]),
          const SizedBox(height: 8),
          Text(body,
              style: GoogleFonts.manrope(
                  fontSize: 14, height: 1.55, color: AppTheme.neutral800)),
        ]),
      );

  // "How to interpret the report" → opens the full-screen guide.
  Widget _interpretCta(BuildContext context, S s, JourneyMilestone m,
          ScanGuide guide, AppLanguage lang) =>
      Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            fullscreenDialog: true,
            builder: (_) => _ScanInterpretScreen(
                controller: controller, milestone: m, guide: guide),
          )),
          child: Ink(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppTheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: _scanColor.withValues(alpha: 0.4)),
            ),
            child: Row(children: [
              const Icon(Icons.fact_check_rounded, color: _scanColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.scnHowToInterpret,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 15,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.primary900)),
                      const SizedBox(height: 2),
                      Text(s.scnInterpretSub,
                          style: GoogleFonts.manrope(
                              fontSize: 12.5, color: AppTheme.neutral600)),
                    ]),
              ),
              const Icon(Icons.chevron_right_rounded,
                  color: AppTheme.neutral400),
            ]),
          ),
        ),
      );
}

// ---------------------------------------------------------------------------
//  Full-screen "How to interpret your report" — glossary + clear disclaimer
// ---------------------------------------------------------------------------
class _ScanInterpretScreen extends StatelessWidget {
  const _ScanInterpretScreen(
      {required this.controller, required this.milestone, required this.guide});
  final PregnancyController controller;
  final JourneyMilestone milestone;
  final ScanGuide guide;

  @override
  Widget build(BuildContext context) {
    final s = S(controller.language);
    final lang = controller.language;
    return Scaffold(
      backgroundColor: AppTheme.surfaceContainer,
      appBar: AppBar(
        backgroundColor: _scanColor,
        foregroundColor: Colors.white,
        title: Text(s.scnHowToInterpret),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
        children: [
          Text('${milestone.emoji} ${milestone.title.of(lang)}',
              style: GoogleFonts.fraunces(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: AppTheme.primary900)),
          const SizedBox(height: 4),
          Text(s.scnInterpretHeading,
              style:
                  GoogleFonts.manrope(fontSize: 13, color: AppTheme.neutral600)),
          const SizedBox(height: 16),
          // BIG, unmissable "not for diagnosis" disclaimer.
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF6E9),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0x33D9822B)),
            ),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.health_and_safety_outlined,
                  size: 22, color: Color(0xFFB36B12)),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.scnInterpretDisclaimerTitle,
                          style: GoogleFonts.plusJakartaSans(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: const Color(0xFFB36B12))),
                      const SizedBox(height: 4),
                      Text(s.scnInterpretDisclaimer,
                          style: GoogleFonts.manrope(
                              fontSize: 12.5,
                              height: 1.5,
                              color: AppTheme.neutral800)),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 18),
          for (final row in guide.interpret) _interpretRow(row, lang),
        ],
      ),
    );
  }

  Widget _interpretRow(ScanInterpretRow row, AppLanguage lang) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.outlineVariant),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(row.term.of(lang),
              style: GoogleFonts.plusJakartaSans(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: _scanColor)),
          const SizedBox(height: 4),
          Text(row.meaning.of(lang),
              style: GoogleFonts.manrope(
                  fontSize: 14, height: 1.5, color: AppTheme.neutral800)),
        ]),
      );
}

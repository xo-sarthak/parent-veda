// =============================================================================
//  ScansAppointmentsScreen - "Scans & Appointments" care roadmap
// -----------------------------------------------------------------------------
//  Calm, confidence-building roadmap (not hospital software): Upcoming /
//  Completed / Care Roadmap. Scan content is reused from kJourneyMilestones
//  (medical). Mark a scan completed → a Journal "Scans" entry; add an
//  appointment → it appears in the Calendar's "Appointment" lane.
//
//  ⚠️ ONE PARENTVEDA (2026-09-30, the pregnancy restyle, after main's TTC
//  appointments screen). The app bar carries the back arrow and the one add
//  control; the serif page title sits on the page. The next scan is one white
//  card with the one ink button; the rest of the run is one white card of
//  rows with drawn marks (the scan's fan), because each row opens the scan;
//  appointments and completed scans are logged data, so they carry a small
//  glyph, not a mark. The teal accent, the soft shadows, the gradient hero,
//  the tinted "what is this scan" block and the amber disclaimer are gone.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/journey_milestones.dart';
import '../../data/scan_guide_data.dart';
import '../../localization/app_language.dart';
import '../../models/journey_node.dart';
import '../../models/scan_appointment.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/scans_store.dart';
// Still read by the Roadmap rows below, which are kept for revert.
import '../../theme/app_theme.dart';
import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart';
import '../doors/pv_list_row.dart' show PvMarkWell;
import '../pregnancy/preg_chrome.dart';
import '../products/pv_store_chrome.dart' show PvChip, kPvInk, kPvLine, pvStorePalette;

// Kept for the Roadmap rows (unreached, kept for revert); nothing live draws
// in the teal since 2026-09-30.
const Color _scanColor = Color(0xFF2E9C8E); // teal - matches Journal "Scans"
const List<BoxShadow> _soft = [
  BoxShadow(color: Color(0x0F2D144C), blurRadius: 12, offset: Offset(0, 3)),
];

/// The Tools tab's "Track" hue, the same one the Tests & scans library wears.
const double _kHue = 206;

List<JourneyMilestone> _allScans() {
  final list = kJourneyMilestones
      .where((m) => m.type == JourneyNodeType.medical)
      .toList()
    ..sort((a, b) => a.anchorWeek.compareTo(b.anchorWeek));
  return list;
}

/// A pushed pregnancy page's app bar: the ground, the back arrow in ink, no
/// title (the page draws its own, in the serif).
PreferredSizeWidget _pregAppBar({List<Widget>? actions}) {
  final pal = pvStorePalette;
  return AppBar(
    backgroundColor: pal.ground,
    surfaceTintColor: Colors.transparent,
    elevation: 0,
    scrolledUnderElevation: 0,
    foregroundColor: pal.ink1,
    actions: actions,
  );
}

/// The one outlined button: white, an ink hairline, ink words, a stadium.
ButtonStyle _pregOutlineStyle() => OutlinedButton.styleFrom(
      foregroundColor: kPvInk,
      side: const BorderSide(color: kPvInk, width: 1.2),
      shape: const StadiumBorder(),
    );

/// A white card of logged rows (appointments, completed scans): hairlines
/// between them, indented past the small glyph.
Widget _loggedCard(List<Widget> rows) => Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: kPvLine),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0)
            const Divider(
                height: 1, thickness: 1, color: kPvLine, indent: 48, endIndent: 16),
          rows[i],
        ],
      ]),
    );

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
    final pal = pvStorePalette;
    return Scaffold(
      backgroundColor: pal.ground,
      // Kept for revert: the title in the app bar,
      //   title: Text(s.scnTitle, style: pvJakarta(
      //       fontWeight: FontWeight.w700, color: AppTheme.neutral900)),
      appBar: _pregAppBar(actions: [
        IconButton(
          tooltip: s.scnAddAppt,
          // A plain add, the line icon for a control. Kept for revert:
          // `Icons.add_circle_outline_rounded`.
          icon: const Icon(Icons.add_rounded),
          onPressed: () => _addAppt(s),
        ),
      ]),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          Semantics(
            header: true,
            child: Text(s.scnTitle, style: pregPageTitleStyle()),
          ),
          const SizedBox(height: 18),
          _segmented(s),
          const SizedBox(height: 16),
          if (_tab == 0) ..._upcoming(s) else ..._completed(s),
        ],
      ),
    );
  }

  // The chosen tab is the one ink with white words, on a white track with the
  // hairline. Kept for revert: the teal fill on a shadowed white track.
  Widget _segmented(S s) {
    // Care roadmap removed - Roadmap tab dropped. _roadmap/_roadmapRow kept
    // (ignore: unused_element) for revert.
    final pal = pvStorePalette;
    final tabs = [s.scnTabUpcoming, s.scnTabCompleted];
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: kPvLine),
      ),
      child: Row(children: [
        for (int i = 0; i < tabs.length; i++)
          Expanded(
            child: Semantics(
              button: true,
              selected: _tab == i,
              child: GestureDetector(
                onTap: () => setState(() => _tab = i),
                behavior: HitTestBehavior.opaque,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: _tab == i ? kPvInk : Colors.transparent,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(tabs[i],
                      textAlign: TextAlign.center,
                      style: pvManrope(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                          color: _tab == i ? Colors.white : pal.ink2)),
                ),
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
      if (upcomingScans.length > 1) {
        out.add(const SizedBox(height: 14));
        // One white card of rows (the TTC list). Kept for revert: each scan
        // was its own shadowed card, 10 apart.
        out.add(PregRowCard(children: [
          for (final m in upcomingScans.skip(1)) _scanRow(s, lang, m),
        ]));
      }
    }
    if (appts.isNotEmpty) {
      out.add(const SizedBox(height: 26));
      // A page section: the one serif heading. Kept for revert:
      //   out.add(_sectionTitle(s.scnAppts));
      out.add(PregSectionHeading(s.scnAppts));
      out.add(const SizedBox(height: 12));
      out.add(_loggedCard([for (final a in appts) _apptRow(s, a)]));
    }
    return out;
  }

  // The next scan: a white card with the hairline, a group label, the name in
  // the serif, the one ink button and an outlined second. Kept for revert: a
  // teal-to-white gradient card with a teal eyebrow, the scan's emoji before
  // its name, a teal filled "Learn more".
  Widget _nextUpHero(S s, AppLanguage lang, JourneyMilestone m) {
    final pal = pvStorePalette;
    final n = _scanDate(m).difference(DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day))
        .inDays;
    final why = m.sections.isNotEmpty ? m.sections.first.body.of(lang) : '';
    return PregCard(
      padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          PvMarkWell(p: pal, hue: _kHue, size: 40, mark: IntentMark.scanFan),
          const SizedBox(width: 12),
          Expanded(child: Text(s.scnNextUp, style: pregGroupLabelStyle())),
        ]),
        const SizedBox(height: 12),
        // No emoji before the name (no decorative emoji in chrome). Kept for
        // revert: Text('${m.emoji} ${m.title.of(lang)}', ...).
        Text(m.title.of(lang),
            style: pvFraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.3,
                color: pal.ink1)),
        const SizedBox(height: 4),
        Text(
            '${m.rangeLabel?.of(lang) ?? s.jrWeekLabel(m.anchorWeek)} · ${s.calInDays(n < 0 ? 0 : n)}',
            style: pvManrope(
                fontSize: 12.5, fontWeight: FontWeight.w600, color: pal.ink2)),
        if (why.isNotEmpty) ...[
          const SizedBox(height: 10),
          Text(why,
              style: pvManrope(fontSize: 13.5, height: 1.5, color: pal.ink2)),
        ],
        const SizedBox(height: 16),
        Row(children: [
          Expanded(
            child: FilledButton(
              style: pregFilledStyle(),
              onPressed: () => _openScan(s, m),
              // ⚠️ THE LABEL NAMES WHAT IT OPENS: the scan's own page. Hindi
              // keeps its words. Kept for revert: Text(s.scnLearnMore).
              child: Text(lang.isHindi ? s.scnLearnMore : 'About this scan'),
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton(
            style: _pregOutlineStyle(),
            onPressed: () => _markDone(s, m),
            child: Text(s.scnMarkDone),
          ),
        ]),
      ]),
    );
  }

  // A row that opens the scan: the scan's fan in the Track hue, the name, its
  // window. Kept for revert: a shadowed card with a teal-tinted line icon
  // (`Icons.medical_services_rounded`, or a check when completed).
  Widget _scanRow(S s, AppLanguage lang, JourneyMilestone m) {
    final completed = ScansStore.instance.isCompleted(m.id);
    return PregOfferRow(
      mark: completed ? IntentMark.checkMark : IntentMark.scanFan,
      hue: _kHue,
      title: m.title.of(lang),
      line: m.rangeLabel?.of(lang) ?? s.jrWeekLabel(m.anchorWeek),
      onTap: () => _openScan(s, m),
    );
  }

  // --- Completed -------------------------------------------------------------
  // Logged data: a small tick glyph, the name, the date. One white card of
  // rows. Kept for revert: a shadowed card per scan with a teal check.
  List<Widget> _completed(S s) {
    final lang = p.language;
    final pal = pvStorePalette;
    final scans = _allScans()
        .where((m) => ScansStore.instance.isCompleted(m.id))
        .toList();
    final doneAppts = ScansStore.instance.appointments
        .where((a) => a.date.isBefore(DateTime.now()))
        .toList();
    if (scans.isEmpty && doneAppts.isEmpty) return [_note(s.scnNoCompleted)];
    // ⚠️ UNCHANGED: past appointments only decide whether the empty line
    // shows; the list itself was only ever the completed scans.
    if (scans.isEmpty) return const [];
    return [
      _loggedCard([
        for (final m in scans)
          Builder(builder: (context) {
            final c = ScansStore.instance.completedOf(m.id);
            final d = DateTime.tryParse(c?.dateIso ?? '');
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
              child: Row(children: [
                Icon(Icons.check_circle_rounded, color: pal.ink1, size: 20),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(m.title.of(lang),
                      style: pvManrope(
                          fontSize: 14.5,
                          fontWeight: FontWeight.w700,
                          color: pal.ink1)),
                ),
                if (d != null)
                  Text(s.formatShortDate(d),
                      style: pvManrope(fontSize: 12, color: pal.ink3)),
              ]),
            );
          }),
      ]),
    ];
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
        : (current ? AppTheme.neutral900 : AppTheme.neutral300);
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Column(children: [
          Container(
            width: 18,
            height: 18,
            margin: const EdgeInsets.only(top: 14),
            decoration: BoxDecoration(
              color: completed ? _scanColor : (current ? AppTheme.neutral900 : AppTheme.surface),
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
                      ? AppTheme.neutral900.withValues(alpha: 0.06)
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
                            style: pvJakarta(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: AppTheme.neutral900)),
                        Text(sub,
                            style: pvManrope(
                                fontSize: 11.5, color: AppTheme.neutral500)),
                      ],
                    ),
                  ),
                  if (current)
                    Text(s.youAreHere,
                        style: pvManrope(
                            fontSize: 9.5,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.neutral900)),
                ]),
              ),
            ),
          ),
        ),
      ]),
    );
  }

  // --- helpers ---------------------------------------------------------------
  // Kept for revert: the Jakarta 15 heading, replaced by `PregSectionHeading`.
  // ignore: unused_element
  Widget _sectionTitle(String t) => Text(t,
      style: pvJakarta(
          fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.neutral900));

  // An appointment is logged data: a small glyph, not a drawn mark, inside the
  // white card. Kept for revert: a shadowed card with a green-tinted icon well
  // and an X to delete (an X only closes now; delete is the bin).
  Widget _apptRow(S s, Appointment a) {
    final pal = pvStorePalette;
    final sub = [a.time, a.location, a.doctor]
        .where((x) => x.trim().isNotEmpty)
        .join(' · ');
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 10, 4, 10),
      child: Row(children: [
        Icon(Icons.event_available_outlined, color: pal.ink2, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(a.title,
                  style: pvManrope(
                      fontSize: 14.5,
                      fontWeight: FontWeight.w700,
                      color: pal.ink1)),
              const SizedBox(height: 2),
              Text('${s.formatShortDate(a.date)}${sub.isNotEmpty ? ' · $sub' : ''}',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: pvManrope(fontSize: 12.5, color: pal.ink3)),
            ],
          ),
        ),
        IconButton(
          icon: Icon(Icons.delete_outline_rounded, size: 20, color: pal.ink3),
          onPressed: () => ScansStore.instance.deleteAppointment(a.id),
        ),
      ]),
    );
  }

  // An empty tab still draws its card, with the line in it (a feature is
  // never hidden). Kept for revert: the line alone, centred, 40 down.
  Widget _note(String msg) => PregRowCard(empty: msg, children: const []);

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
    final pal = pvStorePalette;

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
              color: Colors.white,
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
                            color: kPvLine,
                            borderRadius: BorderRadius.circular(99))),
                  ),
                  const SizedBox(height: 16),
                  Text(s.scnAddAppt,
                      style: pvFraunces(
                          fontSize: 22,
                          fontWeight: FontWeight.w600,
                          height: 1.2,
                          color: pal.ink1)),
                  const SizedBox(height: 14),
                  // The store's hairline chip, ink when chosen. Kept for
                  // revert: a hand-drawn pill, teal when chosen.
                  Wrap(spacing: 8, runSpacing: 8, children: [
                    for (final t in ApptType.values)
                      PvChip(
                        label: typeLabel(t),
                        selected: type == t,
                        onTap: () => setSheet(() => type = t),
                      ),
                  ]),
                  const SizedBox(height: 14),
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
                          color: Colors.white,
                          border: Border.all(color: kPvLine),
                          borderRadius: BorderRadius.circular(14)),
                      child: Row(children: [
                        Icon(Icons.calendar_today_rounded,
                            size: 18, color: pal.ink2),
                        const SizedBox(width: 12),
                        Text(s.formatLongDate(date),
                            style: pvManrope(fontSize: 13.5, color: pal.ink1)),
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
                      style: pregFilledStyle(),
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

  // A white field with the hairline, ink when focused. Kept for revert: a
  // filled grey field with no border (a tint behind text).
  Widget _field(String hint, TextEditingController c, {int max = 1}) {
    final pal = pvStorePalette;
    OutlineInputBorder b(Color color, [double w = 1]) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: color, width: w));
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        minLines: 1,
        maxLines: max,
        style: pvManrope(fontSize: 14.5, color: pal.ink1),
        decoration: InputDecoration(
          hintText: hint,
          hintStyle: pvManrope(fontSize: 14, color: pal.ink3),
          filled: true,
          fillColor: Colors.white,
          border: b(kPvLine),
          enabledBorder: b(kPvLine),
          focusedBorder: b(kPvInk, 1.4),
        ),
      ),
    );
  }
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
    final pal = pvStorePalette;
    final blocks = <Widget>[
      for (final sec in m.sections)
        if (sec.body.of(lang).trim().isNotEmpty)
          _block(sec.label.of(lang), sec.body.of(lang)),
      for (final b in m.bullets) _bulletBlock(b.label.of(lang), b, lang),
    ];

    return Scaffold(
      backgroundColor: pal.ground,
      // ⚠️ THE NAME IS SAID ONCE. It was in the app bar and again, with its
      // emoji, beside a teal icon well a centimetre below. Kept for revert:
      //   title: Text(m.title.of(lang), style: pvJakarta(
      //       fontWeight: FontWeight.w700, color: AppTheme.neutral900)),
      appBar: _pregAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          // The scan's drawn mark over the serif title. Kept for revert: a
          // teal-tinted `Icons.medical_services_rounded` well beside
          // Text('${m.emoji} ${m.title.of(lang)}') in Fraunces 22.
          PvMarkWell(p: pal, hue: _kHue, size: 48, mark: IntentMark.scanFan),
          const SizedBox(height: 14),
          Semantics(
            header: true,
            child: Text(m.title.of(lang), style: pregPageTitleStyle()),
          ),
          const SizedBox(height: 18),
          // "What is this scan?" - a plain-language intro at the very top.
          if (guide != null) ...[
            _whatIsCard(s, guide.whatIs.of(lang)),
            const SizedBox(height: 12),
          ],
          // The rest of the scan's page, in one white card with a group label
          // over each part. Kept for revert: each part on the page with a
          // teal caps label.
          if (blocks.isNotEmpty) ...[
            PregCard(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 2),
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: blocks),
            ),
            const SizedBox(height: 16),
          ],
          // Important note: a quiet note on the page. Kept for revert: the
          // same words on a grey block (`AppTheme.surfaceContainerHigh`).
          PregNote(s.scnImportantNote),
          const SizedBox(height: 20),
          // "How to interpret the report" → full-screen guide (with disclaimer).
          if (guide != null && guide.interpret.isNotEmpty) ...[
            _interpretCta(context, s, m, guide, lang),
            const SizedBox(height: 16),
          ],
          SizedBox(
            width: double.infinity,
            child: completed
                ? OutlinedButton.icon(
                    style: _pregOutlineStyle(),
                    onPressed: () =>
                        ScansStore.instance.unmarkCompleted(m.id),
                    icon: const Icon(Icons.check_circle_rounded,
                        size: 18, color: kPvInk),
                    label: Text(s.scnMarkedDone),
                  )
                : FilledButton.icon(
                    style: pregFilledStyle(),
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

  Widget _block(String label, String body) {
    final pal = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (label.trim().isNotEmpty) ...[
          Text(label.toUpperCase(), style: pregGroupLabelStyle()),
          const SizedBox(height: 5),
        ],
        Text(body, style: pvManrope(fontSize: 14, height: 1.5, color: pal.ink1)),
      ]),
    );
  }

  Widget _bulletBlock(String label, BulletBlock b, AppLanguage lang) {
    final pal = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(), style: pregGroupLabelStyle()),
        const SizedBox(height: 6),
        for (final item in b.items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 6, right: 8),
                child: Icon(Icons.circle, size: 5, color: pal.ink3),
              ),
              Expanded(
                child: Text(item.of(lang),
                    style: pvManrope(fontSize: 14, height: 1.5, color: pal.ink1)),
              ),
            ]),
          ),
      ]),
    );
  }

  // "What is this scan?" intro card (shown at the very top): a white card with
  // the hairline. Kept for revert: a teal-tinted block with a teal info icon
  // and a teal title (a tint behind text).
  Widget _whatIsCard(S s, String body) {
    final pal = pvStorePalette;
    return PregCard(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(s.scnWhatIs,
            style: pvManrope(
                fontSize: 15, fontWeight: FontWeight.w700, color: pal.ink1)),
        const SizedBox(height: 6),
        Text(body, style: pvManrope(fontSize: 14, height: 1.55, color: pal.ink2)),
      ]),
    );
  }

  // "How to interpret the report" → opens the full guide: a row that opens
  // somewhere, so a drawn mark (the report's page). Kept for revert: a white
  // card with a teal border and a teal `Icons.fact_check_rounded`.
  Widget _interpretCta(BuildContext context, S s, JourneyMilestone m,
          ScanGuide guide, AppLanguage lang) =>
      PregRowCard(children: [
        PregOfferRow(
          mark: IntentMark.reportPage,
          hue: _kHue,
          title: s.scnHowToInterpret,
          line: s.scnInterpretSub,
          onTap: () => Navigator.of(context).push(MaterialPageRoute(
            // ⚠️ A PUSHED PAGE GOES BACK WITH AN ARROW (2026-09-30). It was a
            // `fullscreenDialog`, whose app bar draws an X, on a page opened
            // from the scan's own. Kept for revert: fullscreenDialog: true,
            builder: (_) => _ScanInterpretScreen(
                controller: controller, milestone: m, guide: guide),
          )),
        ),
      ]);
}

// ---------------------------------------------------------------------------
//  Full-screen "How to interpret your report" - glossary + clear disclaimer
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
    final pal = pvStorePalette;
    return Scaffold(
      backgroundColor: pal.ground,
      // Kept for revert: a teal app bar with white words,
      //   AppBar(backgroundColor: _scanColor, foregroundColor: Colors.white,
      //       title: Text(s.scnHowToInterpret)),
      appBar: _pregAppBar(),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
        children: [
          Semantics(
            header: true,
            child: Text(s.scnHowToInterpret, style: pregPageTitleStyle()),
          ),
          const SizedBox(height: 6),
          // The scan, named once, without its emoji. Kept for revert:
          // Text('${milestone.emoji} ${milestone.title.of(lang)}') in the serif.
          Text(milestone.title.of(lang),
              style: pvManrope(
                  fontSize: 15, fontWeight: FontWeight.w700, color: pal.ink1)),
          const SizedBox(height: 4),
          Text(s.scnInterpretHeading,
              style: pvManrope(fontSize: 13, height: 1.45, color: pal.ink2)),
          const SizedBox(height: 16),
          // BIG, unmissable "not for diagnosis" disclaimer: a white card with
          // the hairline, first on the page, so it is read before the terms.
          // Kept for revert: an amber block (0xFFFFF6E9) with amber words.
          PregCard(
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.health_and_safety_outlined, size: 22, color: pal.ink1),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(s.scnInterpretDisclaimerTitle,
                          style: pvManrope(
                              fontSize: 14.5,
                              fontWeight: FontWeight.w800,
                              color: pal.ink1)),
                      const SizedBox(height: 4),
                      Text(s.scnInterpretDisclaimer,
                          style: pvManrope(
                              fontSize: 12.5, height: 1.5, color: pal.ink2)),
                    ]),
              ),
            ]),
          ),
          const SizedBox(height: 16),
          // Every term in one white card, hairlines between. Kept for revert:
          // a bordered box per term, the term in teal.
          PregCard(
            padding: EdgeInsets.zero,
            child: Column(children: [
              for (var i = 0; i < guide.interpret.length; i++) ...[
                if (i > 0) const Divider(height: 1, thickness: 1, color: kPvLine),
                _interpretRow(guide.interpret[i], lang),
              ],
            ]),
          ),
        ],
      ),
    );
  }

  Widget _interpretRow(ScanInterpretRow row, AppLanguage lang) {
    final pal = pvStorePalette;
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(row.term.of(lang),
            style: pvManrope(
                fontSize: 14.5, fontWeight: FontWeight.w800, color: pal.ink1)),
        const SizedBox(height: 4),
        Text(row.meaning.of(lang),
            style: pvManrope(fontSize: 14, height: 1.5, color: pal.ink2)),
      ]),
    );
  }
}

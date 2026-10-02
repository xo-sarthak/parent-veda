// =============================================================================
//  PvDoctorNotesScreen — what she has logged, laid out for the appointment
// -----------------------------------------------------------------------------
//  Flo's "Report for a doctor" (docs/PROFILE-AUDIT.md §3), built cheap and
//  honest, the user's call (2026-09-19): a READ-ONLY assembly of what the
//  stores already hold, in the order a doctor asks — who, the dates that
//  matter, what she takes, what she has measured, what is booked. Nothing is
//  asked of her here; nothing is computed. A section with nothing in it says
//  so and names the tool that fills it.
//
//  ⚠️ NEVER A DIAGNOSIS, NEVER AN INTERPRETATION. This page repeats her own
//  entries. It does not say what they mean; the person she hands it to does.
//  It ends on the disclaimer every clinical surface ends on.
//
//  Sharing is the OS share sheet with the same text — a screenshot works too,
//  which is how most parents will actually use it.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';

import '../../screens/post_pregnancy/pp_child_profile.dart';
import '../../screens/post_pregnancy/pp_growth_data.dart';
import '../../screens/post_pregnancy/pp_vaccine_data.dart';
import '../../services/family_profile.dart';
import '../../models/pv_product.dart' show PvStageCopy;
import '../../services/life_stage_store.dart';
import '../../services/medicine_store.dart';
import '../../services/pregnancy_controller.dart';
import '../../services/tools_store.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_doctor_questions_store.dart';
import '../../ttc/ttc_records_store.dart';
import '../../ttc/ttc_treatment_store.dart';
import '../ttc/ttc_appointments_screen.dart'
    show TtcAppointmentsScreen, ttcVisitName;
import '../tools/baby_movement_screen.dart';
import '../tools/medicine_tracker_screen.dart';
import '../tools/weight_tracker_screen.dart';
import '../ttc/ttc_medication_screen.dart' show TtcMedicationScreen;
import '../ttc/ttc_records_screen.dart' show TtcRecordsScreen;
import 'pv_details_screen.dart';
import 'pv_you_chrome.dart';
import 'pv_you_content.dart';

class PvDoctorNotesScreen extends StatefulWidget {
  const PvDoctorNotesScreen({super.key, required this.stage});
  final LifeStage stage;

  @override
  State<PvDoctorNotesScreen> createState() => _PvDoctorNotesScreenState();
}

/// Where a section can be edited: what the button says, and the screen it opens.
///
/// ⚠️ ADDED 2026-10-02 (the user: "when the user is on this screen they might get
/// confused, do I have to go back and find where to edit? provide a gate from
/// here"). This page is read-only by design (it repeats her entries and does
/// not interpret them), so the way to change one is a door to the place that
/// owns it, never an editor here. Each label names its place.
class _Edit {
  const _Edit(this.label, this.route, this.build);
  final String label;
  final String route;
  final Widget Function() build;
}

class _PvDoctorNotesScreenState extends State<PvDoctorNotesScreen> {
  LifeStage get stage => widget.stage;

  String get _stageId => switch (stage.shopStage) {
        LifeStage.tryingToConceive => 'trying',
        LifeStage.pregnancy => 'pregnancy',
        LifeStage.parenting => 'parenting',
        LifeStage.skilling => 'skilling',
      };

  /// The screen the profile's "Change your answers" opens.
  _Edit get _details => _Edit('Edit your details', 'you/details',
      () => PvDetailsScreen(stageId: _stageId));

  /// Opens the place that owns a section, then rebuilds: this page reads the
  /// stores each time it builds, so the change shows the moment she is back.
  Future<void> _go(_Edit e) async {
    await Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: e.route), builder: (_) => e.build()));
    if (mounted) setState(() {});
  }

  static String _d(DateTime d) {
    const m = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec',
    ];
    return '${d.day} ${m[d.month - 1]} ${d.year}';
  }

  /// The sections as (title, lines, emptyHint). Built once for the screen and
  /// once for the share text so the two can never differ.
  List<(String, List<String>, String, _Edit?)> _sections() {
    final s = stage.shopStage;
    final out = <(String, List<String>, String, _Edit?)>[];
    final content = pvYouContentFor(stage);

    // Who, and the facts on the profile.
    out.add((
      'About',
      [
        content.clock(),
        for (final d in content.details)
          if (d.value() != '--') '${d.label}: ${d.value()}',
      ],
      'Fill in Your details on the You screen.',
      _details,
    ));

    if (s == LifeStage.tryingToConceive) {
      final t = TtcTreatmentStore.instance;
      out.add((
        'Treatment dates',
        [
          for (final e in t.cycle.dates.entries)
            '${e.key.label(false)}: ${_d(e.value)}',
        ],
        'No clinic dates logged. Treatment dates live under Your details.',
        _details,
      ));
      out.add((
        'Test records',
        [
          for (final r in TtcRecordsStore.instance.records.take(12))
            '${_d(r.takenOn)} · ${r.label}: ${r.display}${r.forPartner ? ' (partner)' : ''}',
        ],
        'No readings logged. Records live under Your details.',
        _Edit('Open records', 'ttc/records', () => const TtcRecordsScreen()),
      ));
    }

    if (s == LifeStage.pregnancy) {
      final c = PregnancyController.current;
      final tools = ToolsStore.instance;
      out.add((
        'Weight',
        [
          if (tools.prePregnancyWeight != null)
            'Before pregnancy: ${tools.prePregnancyWeight} kg',
          for (final w in tools.weightEntries.take(8))
            'Week ${w.week} (${w.dateIso}): ${w.weight} kg',
        ],
        'No weight logged. The weight tracker is under Tools.',
        c == null
            ? null
            : _Edit('Open weight tracker', 'tools/weight',
                () => WeightTrackerScreen(controller: c)),
      ));
      out.add((
        'Movements',
        [
          if (c != null && tools.movementSessionHistory.isNotEmpty)
            for (final m in tools.movementSessionHistory.take(5))
              'Session: ${m.times.length} movements',
        ],
        'No movement sessions yet. The tracker is under Tools.',
        c == null
            ? null
            : _Edit('Open movement tracker', 'tools/movement',
                () => BabyMovementScreen(controller: c)),
      ));
    }

    if (s == LifeStage.parenting) {
      final child = ChildProfileStore.instance;
      if (child.hasRealChild) {
        final fam = FamilyProfileStore.instance;
        out.add((
          child.active.name,
          [
            'Born ${_d(child.dob)} · ${child.ageLabel} · ${child.isBoy ? 'boy' : 'girl'}',
            if (fam.premature) 'Born early',
            if (fam.nicu) 'NICU stay',
            if (fam.multiple) 'A twin or multiple',
            if (fam.conditions.isNotEmpty)
              'Conditions: ${fam.conditions.map((e) => e.label).join(', ')}',
            if (fam.feedings.isNotEmpty)
              'Feeding: ${fam.feedings.map((e) => e.label).join(', ')}',
            if (fam.sleeps.isNotEmpty)
              'Sleep: ${fam.sleeps.map((e) => e.label).join(', ')}',
          ],
          '',
          _details,
        ));
        out.add((
          'Growth',
          [
            for (final g in GrowthStore.instance.chronological.reversed.take(6))
              '${_d(g.date)}: ${g.weightKg} kg · ${g.heightCm} cm${g.headCm != null ? ' · head ${g.headCm} cm' : ''}',
          ],
          'No measurements yet. Growth is under Tools.',
          null,
        ));
        final vax = VaxStore.instance;
        out.add((
          'Vaccinations done',
          [
            for (final v in kVaxVisits)
              if (vax.isDone(v.id)) '${v.ageLabel}: done',
          ],
          'None marked done yet. The vaccination schedule is under Health.',
          null,
        ));
      }
    }

    // Medicines — every stage.
    final meds = MedicineStore.instance.activeMeds;
    out.add((
      'Medicines and supplements',
      [
        for (final m in meds)
          '${m.name}${m.dose.isNotEmpty ? ' · ${m.dose}' : ''}${m.frequency.isNotEmpty ? ' · ${m.frequency}' : ''}',
      ],
      'None recorded. Medicines live under Tools.',
      // Pregnancy's tracker needs her pregnancy; trying to conceive has its own.
      s == LifeStage.pregnancy && PregnancyController.current != null
          ? _Edit('Open medicines', 'tools/medicines',
              () => MedicineTrackerScreen(
                  controller: PregnancyController.current!))
          : s == LifeStage.tryingToConceive
              ? _Edit('Open medicines', 'ttc/medication',
                  () => const TtcMedicationScreen())
              : null,
    ));

    // ⚠️ LAST, AND TRYING TO CONCEIVE ONLY (2026-09-28): the questions she
    // saved for the next visit, so the note she hands over ends on what she
    // came to ask. Only the unticked ones kept for that visit (or, with no
    // visit booked, the ones waiting for one); her own first, then her
    // partner's, said as his. Read-only here, like everything on this page.
    if (s == LifeStage.tryingToConceive) {
      final qs = TtcDoctorQuestionsStore.instance;
      final next = qs.nextVisit();
      final list = next == null ? qs.waitingForAVisit() : qs.openFor(next.id);
      out.add((
        next == null
            ? 'Questions to ask'
            : 'Questions to ask at the ${ttcVisitName(next)}',
        [
          for (final q in list)
            q.isMine ? q.text : '${q.text} (from your partner)',
        ],
        'No questions saved. Write them on Appointments, under Tools.',
        _Edit('Open appointments', 'ttc/appointments',
            () => const TtcAppointmentsScreen()),
      ));
    }

    return out;
  }

  String _shareText() {
    final b = StringBuffer('Notes for my doctor — from ParentVeda\n');
    for (final (title, lines, _, _) in _sections()) {
      if (lines.isEmpty) continue;
      b.writeln('\n$title');
      for (final l in lines) {
        b.writeln('• $l');
      }
    }
    b.writeln('\nThese are my own entries, not a diagnosis.');
    return b.toString();
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    final sections = _sections();
    return Scaffold(
      backgroundColor: p.ground,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: PvYouTopBar(
              title: 'Notes for your doctor',
              eyebrow: 'Your things',
              trailing: PvRoundIcon(
                icon: Icons.ios_share_rounded,
                onTap: () => Share.share(_shareText()),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 0),
              child: Text(
                'Everything you have logged, in the order a doctor asks. Show the screen, or share it as text. Nothing here is interpreted — that is their job.',
                style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2),
              ),
            ),
          ),
          for (final (title, lines, empty, edit) in sections)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 18, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Expanded(
                          child: Text(
                            title,
                            style: pvFraunces(
                              fontSize: 19,
                              fontWeight: FontWeight.w500,
                              color: p.ink1,
                            ),
                          ),
                        ),
                        // The gate to where this is edited (2026-10-02).
                        if (edit != null)
                          TextButton.icon(
                            key: ValueKey('notes_edit_$title'),
                            onPressed: () => _go(edit),
                            style: TextButton.styleFrom(
                              foregroundColor: p.ink1,
                              minimumSize: const Size(48, 44),
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            ),
                            icon: Icon(Icons.edit_outlined,
                                size: 16, color: p.ink1),
                            label: Text(
                              edit.label,
                              style: pvManrope(
                                fontSize: 13,
                                fontWeight: FontWeight.w800,
                                color: p.ink1,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: kPvLine),
                      ),
                      child: lines.isEmpty
                          ? Text(
                              empty.isEmpty ? '--' : empty,
                              style: pvManrope(
                                fontSize: 13,
                                height: 1.45,
                                color: p.ink3,
                              ),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                for (final l in lines)
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 5),
                                    child: Text(
                                      l,
                                      style: pvManrope(
                                        fontSize: 13.5,
                                        height: 1.45,
                                        color: p.ink1,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                    ),
                  ],
                ),
              ),
            ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 40),
              child: Text(
                'These are your own entries, laid out — not a diagnosis, and not advice. If your doctor says something different, your doctor is right.',
                style: pvManrope(fontSize: 11.5, height: 1.5, color: p.ink3),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

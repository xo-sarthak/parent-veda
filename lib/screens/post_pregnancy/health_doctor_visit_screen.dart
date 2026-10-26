// =============================================================================
//  HealthDoctorVisitScreen - the Doctor Visit Companion (a key differentiator)
// -----------------------------------------------------------------------------
//  Generates a clean, shareable summary before an appointment - age, growth,
//  vaccinations, current medications, allergies, recent history, recent reports -
//  plus the questions the parent saved for the doctor. Formatted like a printable
//  sheet; PDF share is stubbed. Never a diagnosis - just organised facts.
//
//  ON THE TOOL SHELL (Wave 3, 2026-10-25). The page wears `PregToolScaffold`
//  like every other tool (it was the last purple page in the Health group, and
//  its share button overflowed at 360dp). What changed, and why:
//   · "The last 7 days" (`PpCareHistory`): feeds, sleep and nappies are what a
//     paediatrician asks first, and the family already logged them. On screen
//     as one line; in the shared text as the same summary the care history
//     screen sends (`PpCareHistory.doctorSummary`), so the two never disagree.
//   · A visible "not a diagnosis" line, above the share button.
//   · Growth only once she has entered it (`HealthStore.growthEntered`), the
//     same guard the Health record uses, so a placeholder figure never reaches
//     a doctor.
//   · Symptoms newest first. Their dates are display strings ("12 Jun 2026",
//     what the record writes); a date that does not parse keeps its place
//     after the dated ones, in the order the store holds.
//   · "QUESTIONS TO ASK" leaves the shared text when there are none.
//   · Removing a question says so, with Undo.
//   · The shell's round back replaces the hard-coded "Health" label, which was
//     wrong when the page was opened from the Tools tab.
//  The page before the shell is `_buildBeforeShell`, kept for revert.
// =============================================================================

import 'package:flutter/material.dart';
import 'pp_child_profile.dart';
import 'package:share_plus/share_plus.dart';

import '../../theme/pv_fonts.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvCommit;
import '../v2/v2_palette.dart';
import 'pp_care_log_data.dart' show NappyStore, PpCareDay, PpCareHistory;
import 'pp_care_parts.dart' show ppCareHeading, ppCareSaved;
import 'pp_common.dart';
import 'pp_feeding_data.dart' show FeedingStore;
import 'pp_growth_data.dart';
import 'pp_health_data.dart';
import 'pp_sleep_data.dart' show SleepStore;
import 'pp_vaccine_data.dart';
import 'pp_milestones_data.dart' show MilestoneStore;
import 'pp_baby_food_check_screen.dart' show ppBabyFoodNameOf, ppDayLabel;
import 'pp_food_tries_store.dart';
import '../../services/pp_use_consent.dart';
import '../../widgets/pv_feedback.dart' show PvPress;

/// The words under the summary, on screen and in the shared text.
const String kPpDoctorVisitNotDiagnosis =
    'A summary to help the conversation, not a diagnosis. Your paediatrician knows your baby best.';

// Every line below is HER record. This screen used to print a fictional
// child - "4 months (born 8 Mar 2026) · Boy", a const growth measurement,
// "Up to date", "Vitamin D drops", "Mild cold (early Jun)" - and hand it to a
// doctor via the Share button. Same fix as the Doctor-ready record.
const List<String> _months = [
  'Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec',
];
String _trim(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(1);

HealthStore get _s => HealthStore.instance;

String _childLine() {
  final c = ChildProfileStore.instance;
  final d = c.dob;
  return '${c.name} · ${c.ageLabel} '
      '(born ${d.day} ${_months[d.month - 1]} ${d.year}) · '
      '${c.sexLabel}';
}

String _growthLine() {
  final m = GrowthStore.instance.latest;
  // The Health record's guard (health_home_screen.dart `_growthLine`): only
  // figures she entered, never a placeholder.
  if (m == null || !_s.growthEntered) return 'No measurements recorded yet';
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

String _allergyLine() =>
    _s.allergies.isEmpty ? 'None recorded' : _s.allergies.map((a) => a.name).join(' · ');

/// "12 Jun 2026" (what the record writes) as a date, or null.
DateTime? ppParseRecordDate(String s) {
  final parts = s.trim().split(RegExp(r'\s+'));
  if (parts.length != 3) return null;
  final d = int.tryParse(parts[0]);
  final mon = parts[1].length >= 3 ? parts[1].substring(0, 3).toLowerCase() : '';
  final m = _months.indexWhere((x) => x.toLowerCase() == mon);
  final y = int.tryParse(parts[2]);
  if (d == null || m < 0 || y == null) return null;
  return DateTime(y, m + 1, d);
}

/// Newest first by date; an undated entry keeps its store order after the
/// dated ones (a stable sort, so nothing reshuffles at random).
List<SymptomEntry> ppSymptomsNewestFirst(List<SymptomEntry> list) {
  final indexed = [for (var i = 0; i < list.length; i++) (i, list[i], ppParseRecordDate(list[i].date))];
  indexed.sort((a, b) {
    final da = a.$3, db = b.$3;
    if (da != null && db != null) {
      final c = db.compareTo(da);
      return c != 0 ? c : a.$1.compareTo(b.$1);
    }
    if (da != null) return -1;
    if (db != null) return 1;
    return a.$1.compareTo(b.$1);
  });
  return [for (final x in indexed) x.$2];
}

String _historyLine() {
  final list = ppSymptomsNewestFirst(_s.symptoms);
  return list.isEmpty ? 'None recorded' : list.take(3).map((x) => '${x.name} (${x.date})').join(' · ');
}

/// Milestones seen in the last three months, only with her yes to
/// "Milestones and check-in answers" (tools pass, Development, 2026-10-25).
/// Null without it: the row is then not shown, and the screen says how to
/// add it. The check-in's "not yet" answers reach the visit as questions,
/// added from the check-in itself.
String? ppDoctorVisitDevelopmentLine({DateTime? now}) {
  if (!PpUseConsent.instance.allows(PpUseKind.development)) return null;
  final ms = MilestoneStore.instance;
  final since = (now ?? DateTime.now()).subtract(const Duration(days: 92));
  // `seen`, not `achieved`, since R10: a milestone of her own counts too.
  // Kept for revert:
  // final recent = ms.achieved.where((m) => ms.observation(m.id)!.date.isAfter(since)).toList();
  // if (recent.isEmpty) return 'No milestones ticked in the last 3 months';
  final recent = ms.seen.where((s) => s.obs.date.isAfter(since)).toList();
  if (recent.isEmpty) return 'No milestones saved in the last 3 months';
  return 'Seen lately: ${recent.take(5).map((m) => m.title).join(' · ')}';
}

/// First foods that brought a reaction in the last three months, only with
/// her yes to "Foods tried" (tools pass, Food, 2026-10-25). Null without it,
/// or when there is nothing to tell: a doctor needs the reactions, not the
/// whole list of what went well.
String? ppDoctorVisitFoodsLine({DateTime? now}) {
  if (!PpUseConsent.instance.allows(PpUseKind.foods)) return null;
  final since = (now ?? DateTime.now()).subtract(const Duration(days: 92));
  final r = PpFoodTriesStore.instance.reactionsSince(since);
  if (r.isEmpty) return null;
  return r
      .take(5)
      .map((e) => '${ppBabyFoodNameOf(e.key)} (${e.value.reaction.label.toLowerCase()}, ${ppDayLabel(e.value.date)})')
      .join(' · ');
}

String _reportsLine() =>
    _s.reports.isEmpty ? 'None recorded' : _s.reports.take(3).map((r) => '${r.name} (${r.date})').join(' · ');

/// One line for the screen: the last 7 days, averaged over the days logged.
String ppLast7DaysLine(List<PpCareDay> days) {
  final logged = days.where((d) => !d.isEmpty).toList();
  if (logged.isEmpty) return 'Nothing logged in the last 7 days';
  double avg(Iterable<int> xs) {
    final l = xs.where((x) => x > 0).toList();
    return l.isEmpty ? 0 : l.reduce((a, b) => a + b) / l.length;
  }

  String hm(double mins) {
    final h = mins ~/ 60;
    final m = (mins % 60).round();
    return h == 0 ? '${m}m' : (m == 0 ? '${h}h' : '${h}h ${m}m');
  }

  final feeds = avg(logged.map((d) => d.feeds));
  final sleep = avg(logged.map((d) => d.sleepMin));
  final wet = avg(logged.map((d) => d.wet));
  final parts = [
    if (feeds > 0) '${feeds.toStringAsFixed(1)} feeds',
    if (sleep > 0) '${hm(sleep)} sleep',
    if (wet > 0) '${wet.toStringAsFixed(1)} wet nappies',
  ];
  final n = logged.length;
  return '$n ${n == 1 ? 'day' : 'days'} logged'
      '${parts.isEmpty ? '' : ': about ${parts.join(', ')} a day'}';
}

/// The text the Share button sends. Public so a test can read exactly what a
/// doctor would receive.
String ppDoctorVisitShareText({List<PpCareDay>? days}) {
  final c = ChildProfileStore.instance;
  final week = days ?? PpCareHistory.days(7);
  final b = StringBuffer()
    ..writeln('VISIT SUMMARY - ${c.name}')
    ..writeln('Child: ${_childLine()}')
    ..writeln('Growth: ${_growthLine()}')
    ..writeln('Vaccinations: ${_vaxLine()}')
    ..writeln('Medications: ${_medsLine()}')
    ..writeln('Allergies: ${_allergyLine()}')
    ..writeln('Recent history: ${_historyLine()}')
    ..writeln('Recent reports: ${_reportsLine()}')
    ..write(ppDoctorVisitDevelopmentLine() == null ? '' : 'Development: ${ppDoctorVisitDevelopmentLine()}\n')
    ..write(ppDoctorVisitFoodsLine() == null ? '' : 'First foods: ${ppDoctorVisitFoodsLine()}\n')
    ..writeln('')
    ..writeln('THE LAST 7 DAYS')
    ..writeln(PpCareHistory.doctorSummary(week, childName: c.name, ageLabel: c.ageLabel));
  // Hidden when there are none: an empty heading reads as something missing.
  if (_s.questions.isNotEmpty) {
    b
      ..writeln('')
      ..writeln('QUESTIONS TO ASK');
    for (final q in _s.questions) {
      b.writeln('  • $q');
    }
  }
  b
    ..writeln('')
    ..writeln(kPpDoctorVisitNotDiagnosis);
  return b.toString();
}

class HealthDoctorVisitScreen extends StatefulWidget {
  const HealthDoctorVisitScreen({super.key});

  @override
  State<HealthDoctorVisitScreen> createState() => _HealthDoctorVisitScreenState();
}

class _HealthDoctorVisitScreenState extends State<HealthDoctorVisitScreen> {
  final TextEditingController _q = TextEditingController();

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  String _shareText() => ppDoctorVisitShareText();

  @override
  void dispose() {
    _q.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        listenable: Listenable.merge([
          _s,
          GrowthStore.instance,
          VaxStore.instance,
          ChildProfileStore.instance,
          FeedingStore.instance,
          SleepStore.instance,
          NappyStore.instance,
          MilestoneStore.instance,
          PpFoodTriesStore.instance,
          PpUseConsent.instance,
        ]),
        builder: (context, _) {
          final p = V2PaletteStore.instance.current;
          final week = PpCareHistory.days(7);
          return PregToolScaffold(
            hue: 152,
            eyebrow: 'Health',
            mark: IntentMark.listMark,
            title: 'Before you see the doctor',
            intro: 'Questions and a summary to share, gathered from what you have logged.',
            children: [
              pregToolPad(Row(children: [
                Expanded(child: ppCareHeading('Visit summary')),
                const SizedBox(width: 8),
                Text('Prepared today', style: pvManrope(fontSize: 12, fontWeight: FontWeight.w600, color: p.ink3)),
              ])),
              const SizedBox(height: 10),
              pregToolPad(Container(
                key: const ValueKey('pp_doctor_visit_summary'),
                padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: p.line),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  _fact(p, 'Child', _childLine()),
                  _fact(p, 'Growth', _growthLine()),
                  _fact(p, 'Vaccinations', _vaxLine()),
                  _fact(p, 'Medications', _medsLine()),
                  _fact(p, 'Allergies', _allergyLine()),
                  _fact(p, 'Recent symptoms', _historyLine()),
                  _fact(p, 'Recent reports', _reportsLine()),
                  if (ppDoctorVisitDevelopmentLine() case final dev?)
                    _fact(p, 'Development', dev, key: const ValueKey('pp_doctor_visit_development')),
                  if (ppDoctorVisitFoodsLine() case final foods?)
                    _fact(p, 'First foods', foods, key: const ValueKey('pp_doctor_visit_foods')),
                  _fact(p, 'The last 7 days', ppLast7DaysLine(week),
                      key: const ValueKey('pp_doctor_visit_last7'), last: true),
                ]),
              )),
              const SizedBox(height: 26),
              pregToolPad(ppCareHeading('Questions to ask')),
              const SizedBox(height: 4),
              pregToolPad(Text('Save them now, so nothing slips your mind in the room.',
                  style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2))),
              const SizedBox(height: 12),
              for (int i = 0; i < _s.questions.length; i++) pregToolPad(_questionRowShell(p, i, _s.questions[i])),
              const SizedBox(height: 4),
              pregToolPad(_addQuestionShell(p)),
              const SizedBox(height: 22),
              pregToolPad(Text(kPpDoctorVisitNotDiagnosis,
                  key: const ValueKey('pp_doctor_visit_not_diagnosis'),
                  style: pvManrope(fontSize: 13, fontWeight: FontWeight.w600, height: 1.5, color: p.ink2))),
              const SizedBox(height: 14),
              pregToolPad(PvCommit(
                key: const ValueKey('pp_doctor_visit_share'),
                label: 'Share with paediatrician',
                icon: Icons.ios_share_rounded,
                onTap: () => Share.share(_shareText()),
              )),
              const SizedBox(height: 24),
            ],
          );
        },
      );

  Widget _fact(V2Palette p, String label, String value, {Key? key, bool last = false}) => Container(
        key: key,
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 11),
        decoration: BoxDecoration(border: Border(bottom: last ? BorderSide.none : BorderSide(color: p.line))),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(label.toUpperCase(),
              style: pvManrope(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 0.8, color: p.ink3)),
          const SizedBox(height: 3),
          Text(value, style: pvManrope(fontSize: 14, fontWeight: FontWeight.w600, height: 1.45, color: p.ink1)),
        ]),
      );

  void _removeQuestion(int i) {
    final q = _s.questions[i];
    _s.removeQuestion(i);
    // Undo adds it back (at the end of the list: the store has no insert-at).
    ppCareSaved(context, 'Question removed.', undo: () => _s.addQuestion(q));
  }

  Widget _questionRowShell(V2Palette p, int i, String q) => Container(
        key: ValueKey('pp_doctor_visit_q_$i'),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.fromLTRB(15, 6, 4, 6),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: p.line)),
        child: Row(children: [
          Icon(Icons.help_outline_rounded, size: 18, color: p.ink2),
          const SizedBox(width: 12),
          Expanded(child: Text(q, style: pvManrope(fontSize: 14, height: 1.4, color: p.ink1))),
          IconButton(
            tooltip: 'Remove question',
            icon: Icon(Icons.close_rounded, size: 18, color: p.ink3),
            onPressed: () => _removeQuestion(i),
          ),
        ]),
      );

  Widget _addQuestionShell(V2Palette p) => Row(children: [
        Expanded(
          child: TextField(
            key: const ValueKey('pp_doctor_visit_add_q'),
            controller: _q,
            style: pvManrope(fontSize: 14.5, color: p.ink1),
            textCapitalization: TextCapitalization.sentences,
            onSubmitted: (_) => _submit(),
            decoration: InputDecoration(
              hintText: 'Add a question…',
              hintStyle: pvManrope(fontSize: 14.5, color: p.ink3),
              filled: true,
              fillColor: Colors.white,
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 13),
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.line)),
              enabledBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.line)),
              focusedBorder:
                  OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: p.ink1)),
            ),
          ),
        ),
        const SizedBox(width: 10),
        Semantics(
          button: true,
          label: 'Add question',
          child: InkWell(
            onTap: _submit,
            customBorder: const CircleBorder(),
            child: Container(
              width: 44,
              height: 44,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: p.ink1, shape: BoxShape.circle),
              child: const Icon(Icons.add_rounded, size: 22, color: Colors.white),
            ),
          ),
        ),
      ]);

  // ==========================================================================
  //  Kept for revert (2026-10-25): the page before the tool shell, in the old
  //  purple kit, with its hard-coded "Health" back label. The share label is
  //  Flexible here too, so even this build no longer overflows at 360dp.
  // ==========================================================================
  // ignore: unused_element
  Widget _buildBeforeShell(BuildContext context) {
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
              _pad(PvPress(child: GestureDetector(
                onTap: () => Share.share(_shareText()),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                  // Was a bare Text in a centred Row, which overflowed at 360dp
                  // and 1.5x text (2026-10-25).
                  child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.ios_share_rounded, size: 18, color: Colors.white),
                    const SizedBox(width: 8),
                    Flexible(
                      child: Text('Share with paediatrician',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: ppBody(13.5, color: Colors.white, w: FontWeight.w700)),
                    ),
                  ]),
                ),
              ))),
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
          PvPress(child: GestureDetector(onTap: () => _s.removeQuestion(i), behavior: HitTestBehavior.opaque, child: const Padding(padding: EdgeInsets.all(4), child: Icon(Icons.close_rounded, size: 16, color: ppMuted)))),
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
        PvPress(child: GestureDetector(
          onTap: _submit,
          child: Container(width: 44, height: 44, alignment: Alignment.center, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle), child: const Icon(Icons.add_rounded, size: 22, color: Colors.white)),
        )),
      ]);

  void _submit() {
    _s.addQuestion(_q.text);
    _q.clear();
  }
}

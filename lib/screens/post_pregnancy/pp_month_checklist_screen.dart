// =============================================================================
//  PpMonthChecklistScreen — everything about this month, on one page
//  (surface pp_month_checklist), 2026-10-07
// -----------------------------------------------------------------------------
//  Parenting gap analysis, P1 (Tools, and the new section "Development › Month
//  by month checklist"): "theAsianparent's Checklist puts milestones, engaging
//  your baby, immunisation, home care, nappies, sleep, 'contact your doctor
//  if', postpartum care and reminders on one page per age. Build it from what
//  we have (phases, door pages, vaccines, red flags)."
//
//  So nothing here is new writing. Each section reads its owner:
//    * What is new, many children around now, try this  -> kPpMonthNotes (12m+)
//    * Milestones emerging now (tick one when you see it) -> MilestoneStore
//    * Play, sleep, feeding, keeping safe, and you         -> the phase's sections
//    * Vaccines due                                       -> VaxStore (this child's dates)
//    * Call the doctor if                                 -> the phase (and the month note)
//  A tick on a milestone is the tracker's own tick (synced, child-scoped): one
//  record, two ways in. Nothing to keep in step.
//
//  Mobbin: Lifesum's and Noom's day plans (sections of short rows under plain
//  headings, a round tick on the row) and Google Health's "This week" grouping;
//  the shell is the shared tool shell.
//  Mobbin audit (2026-10-07): tick rows for the month's skills, after
//  Walmart's registry checklist (mobbin.com/screens/3409c219-306c-4f9e-ac95-3e79dea946fe);
//  the vaccine as a "due" line with what to do next, after Zocdoc's Well Guide
//  (mobbin.com/screens/86529650-4ea4-42ec-ad0e-a1d14a9c9fb0). Its "0/4
//  complete" bar is declined: a month is not a score.
// =============================================================================

import 'package:flutter/material.dart';

import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../pregnancy/preg_tool_chrome.dart';
import '../v2/v2_palette.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import 'pp_care_parts.dart';
import 'pp_child_profile.dart';
import 'pp_milestones_data.dart';
import 'pp_month_notes.dart';
import 'pp_phases_data.dart';
import 'pp_vaccine_data.dart';
import 'vax_tracker_screen.dart';
import 'pp_search.dart' show ppOpenSurface;
import '../ttc/doors/ttc_tab_art.dart' show TtcTabMark;
import '../ttc/ttc_tool_marks.dart' show TtcMarkLeading;

class PpMonthChecklistScreen extends StatefulWidget {
  const PpMonthChecklistScreen({super.key});

  @override
  State<PpMonthChecklistScreen> createState() => _PpMonthChecklistScreenState();
}

class _PpMonthChecklistScreenState extends State<PpMonthChecklistScreen> {
  @override
  void initState() {
    super.initState();
    MilestoneStore.instance.init();
    VaxStore.instance.init();
  }

  String? _section(AgePhase p, String start) {
    for (final s in p.sections) {
      if (s.heading.toLowerCase().startsWith(start)) return s.paragraphs.join(' ');
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([MilestoneStore.instance, VaxStore.instance, ChildProfileStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final c = ChildProfileStore.instance;
        final phase = currentPhase();
        final note = ppMonthNoteFor(c.devAgeInMonths);
        final ms = MilestoneStore.instance;
        // Was `ms.emerging.take(6)`: the catalogue is in domain order, so six
        // were often all movement, and a ticked row vanished at once (its
        // untick could never run). Now every skill in the window, seen ones
        // kept and ticked, one from each area in turn (tools pass, 2026-10-25).
        final emerging = _byAreaInTurn(ms.inWindow);
        const shown = 8;
        final vax = VaxStore.instance;
        final next = vax.nextVisit;
        final body = pvManrope(fontSize: 14, height: 1.55, color: p.ink1);
        Widget section(String title, Widget child) => pregToolPad(Padding(
              padding: const EdgeInsets.only(bottom: 22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppCareHeading(title),
                const SizedBox(height: 8),
                child,
              ]),
            ));
        final rows = <(String, String?)>[
          ('Play that helps', _section(phase, 'play')),
          ('Sleep', _section(phase, 'sleep')),
          ('Feeding', _section(phase, 'feeding')),
          ('Keeping safe', _section(phase, 'keeping')),
        ];
        final you = _section(phase, 'and you');
        final doctor = _section(phase, 'when to call');
        return PregToolScaffold(
          hue: 28,
          eyebrow: note?.label ?? phase.ageLabel,
          mark: IntentMark.listMark,
          title: 'This month\'s checklist',
          intro: 'Everything for ${c.nameMid}\'s age on one page: what is new, what to watch for, and what is due.',
          children: [
            if (note != null)
              section('What is new', Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(note.whatsNew, style: body),
                const SizedBox(height: 10),
                Text.rich(TextSpan(children: [
                  const TextSpan(text: 'Try this  ', style: TextStyle(fontWeight: FontWeight.w800)),
                  TextSpan(text: note.tryThis),
                ]), style: body),
              ]))
            else
              section('What is new', Text(phase.summary, style: body)),
            section(
              'Skills coming in now',
              emerging.isEmpty
                  ? Text('Nothing new on the list for this age. Keep playing and talking; it all counts.', style: body)
                  : Column(children: [
                      for (final m in emerging.take(shown))
                        _TickRow(
                          key: ValueKey('pp_checklist_ms_${m.id}'),
                          label: m.title,
                          ticked: ms.isObserved(m.id),
                          onTap: () {
                            pvCommitFeedback();
                            if (ms.isObserved(m.id)) {
                              final was = ms.observation(m.id);
                              ms.unobserve(m.id);
                              ppCareSaved(context, '"${m.title}" taken off Milestones.',
                                  undo: () => ms.markObserved(m.id, date: was?.date, note: was?.note));
                            } else {
                              ms.markObserved(m.id);
                              // Was 'saved to the milestone journey.': the tool is Milestones now.
                              ppCareSaved(context, '"${m.title}" saved to Milestones, seen today.',
                                  undo: () => ms.unobserve(m.id));
                            }
                          },
                        ),
                      const SizedBox(height: 4),
                      // Was plain text naming "the milestone journey". Now a
                      // link, and it says how many more there are.
                      InkWell(
                        key: const ValueKey('pp_checklist_all_milestones'),
                        onTap: () => ppOpenSurface(context, 'pp_milestones'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            emerging.length > shown
                                ? 'See all ${emerging.length} in Milestones  →'
                                : 'Ticks go to Milestones  →',
                            style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, color: p.ink1),
                          ),
                        ),
                      ),
                      Text('A skill not here yet is not a worry on its own.',
                          style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
                    ]),
            ),
            for (final (title, text) in rows)
              if (text != null) section(title, Text(text, style: body)),
            section(
              'Vaccines',
              next == null
                  ? Text('Every visit on the schedule is recorded. Well done keeping track.', style: body)
                  : InkWell(
                      key: const ValueKey('pp_checklist_vax'),
                      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                        settings: const RouteSettings(name: 'pp/vaccines'),
                        builder: (_) => const VaxTrackerScreen(),
                      )),
                      child: Row(children: [
                        Expanded(
                          child: Text(
                            'Next: the ${next.ageLabel} visit, ${vax.dateLabelFor(next)}. '
                            '${next.vaccineIds.map((id) => vaccineById(id).shortName).join(', ')}.',
                            style: body,
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded, color: p.ink2),
                      ]),
                    ),
            ),
            if (doctor != null || note != null)
              pregToolPad(Container(
                key: const ValueKey('pp_checklist_doctor'),
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 22),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: p.line),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    // A drawn mark (was Icon(Icons.local_hospital_outlined)).
                    TtcMarkLeading(tab: TtcTabMark.doctorChat, tint: v2BlockTint(28, p), size: 28),
                    const SizedBox(width: 8),
                    Flexible(child: Text('Call the doctor if', style: pvManrope(fontSize: 15, fontWeight: FontWeight.w800, color: p.ink1))),
                  ]),
                  const SizedBox(height: 8),
                  if (doctor != null) Text(doctor, style: body),
                  if (note != null) ...[
                    if (doctor != null) const SizedBox(height: 6),
                    Text('Talk to your doctor if ${note.callIf}', style: body),
                  ],
                  const SizedBox(height: 8),
                  Text('This is general guidance, not a diagnosis. Your own doctor knows ${c.nameMid} best.',
                      key: const ValueKey('pp_checklist_not_a_diagnosis'),
                      style: pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
                ]),
              )),
            if (you != null) section('And you', Text(you, style: body)),
            const SizedBox(height: 24),
          ],
        );
      },
    );
  }
}

/// One skill from each area in turn, so a short list is never all movement.
List<Milestone> _byAreaInTurn(List<Milestone> ms) {
  final byArea = <DevDomain, List<Milestone>>{};
  for (final m in ms) {
    (byArea[m.domain] ??= []).add(m);
  }
  final out = <Milestone>[];
  for (var i = 0; out.length < ms.length; i++) {
    for (final list in byArea.values) {
      if (i < list.length) out.add(list[i]);
    }
  }
  return out;
}

class _TickRow extends StatelessWidget {
  const _TickRow({super.key, required this.label, required this.ticked, required this.onTap});
  final String label;
  final bool ticked;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    const ink = Color(0xFF2F2C30);
    return Semantics(
      button: true,
      checked: ticked,
      label: label,
      excludeSemantics: true,
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 11),
          decoration: BoxDecoration(border: Border(bottom: BorderSide(color: p.line))),
          child: Row(children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: ticked ? ink : Colors.white,
                border: Border.all(color: ticked ? ink : p.line, width: 1.5),
              ),
              child: ticked ? const Icon(Icons.check_rounded, size: 16, color: Colors.white) : null,
            ),
            const SizedBox(width: 12),
            Expanded(child: Text(label, style: pvManrope(fontSize: 14.5, fontWeight: FontWeight.w600, color: p.ink1))),
          ]),
        ),
      ),
    );
  }
}

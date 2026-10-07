// =============================================================================
//  Vaccines — the tracker on the shared tool shell (2026-10-07)
// -----------------------------------------------------------------------------
//  Gap analysis P1 (Behind · Health): "the tracker shows only the private
//  schedule" and "a dose can be ticked but not dated". So:
//    * she says which schedule her paediatrician follows (government UIP,
//      private IAP, not sure). On the government one, a visit made only of
//      private doses reads "optional" and is never "due" or reminded.
//    * marking a visit given asks the day (today by default).
//  Drawn on PregToolScaffold, the shell every TTC and pregnancy tool wears.
//  The old purple screen is `VaxTrackerClassic` in vax_tracker_screen.dart,
//  kept for revert.
//
//  Mobbin: the next visit as a two-tile details pair with its date, after
//  Oura's pregnancy "Details" (mobbin.com/screens/4ccc949c-fa00-41db-a72e-67f4e19f214e);
//  the visits as plain title-and-line rows, after Starling's document list
//  (mobbin.com/screens/b1001e94-7485-48cf-bea3-c158623bd657).
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/family_profile.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_date_sheet.dart';
import '../brackets/hub/hub_intent_art.dart' show IntentMark;
import '../doors/pv_list_row.dart';
import '../pregnancy/preg_tool_chrome.dart';
import '../products/pv_store_chrome.dart' show PvCommit, PvSecondary, pvStorePalette;
import 'doctor_record_screen.dart';
import 'pp_care_parts.dart';
import 'pp_child_profile.dart';
import 'pp_vaccine_data.dart';
import 'vax_detail_screen.dart';

const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
String _day(DateTime d) => '${d.day} ${_months[d.month - 1]} ${d.year}';

/// Mark [v] given, asking the day first. Shared with the visit's own page.
Future<void> ppVaxMarkGiven(BuildContext context, VaxVisit v) async {
  final c = ChildProfileStore.instance;
  final now = DateTime.now();
  final scheduled = c.dob.add(Duration(days: v.ageDays));
  final first = c.dob.isAfter(now) ? now : c.dob;
  final d = await showPvDateSheet(
    context,
    title: 'When was it given?',
    eyebrow: '${v.ageLabel} visit',
    initial: scheduled.isAfter(now) || scheduled.isBefore(first) ? now : scheduled,
    first: first,
    last: now,
  );
  if (d == null || !context.mounted) return;
  VaxStore.instance.markDone(v.id, on: d);
  ppCareSaved(context, 'Recorded: the ${v.ageLabel} visit, given on ${_day(d)}',
      undo: () => VaxStore.instance.markNotDone(v.id));
}

class VaxTrackerScreen extends StatelessWidget {
  const VaxTrackerScreen({super.key});

  void _open(BuildContext context, VaxVisit v) => Navigator.of(context).push(MaterialPageRoute<void>(
        settings: RouteSettings(name: 'pp/vaccines/${v.id}'),
        builder: (_) => VaxDetailScreen(visitId: v.id),
      ));

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return ListenableBuilder(
      listenable: Listenable.merge([VaxStore.instance, FamilyProfileStore.instance, ChildProfileStore.instance]),
      builder: (context, _) {
        final store = VaxStore.instance;
        final c = ChildProfileStore.instance;
        final schedule = FamilyProfileStore.instance.vaxSchedule;
        final next = store.nextVisit;
        final given = kVaxVisits.where((v) => store.isDone(v.id)).length;
        return PregToolScaffold(
          hue: 160,
          eyebrow: 'Health',
          mark: IntentMark.pillMark,
          title: 'Vaccines',
          intro: store.nothingRecorded
              ? 'Tick each visit ${c.name} has had, with the day. It becomes a record any doctor can read.'
              : '$given of ${kVaxVisits.length} visits recorded. The next one is below.',
          children: [
            // ---- which schedule ----
            pregToolPad(ppCareHeading('Which schedule does your paediatrician follow?')),
            const SizedBox(height: 6),
            pregToolPad(Text(
                'Government centres give the UIP vaccines free. Private clinics follow the IAP, '
                'which adds a few more. Either is a full schedule.',
                style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2))),
            const SizedBox(height: 12),
            pregToolPad(ppCareChoices<VaxSchedule>(
              values: VaxSchedule.values,
              selected: schedule,
              label: (s) => s.label,
              onPick: (s) {
                if (s != null) FamilyProfileStore.instance.setVaxSchedule(s);
              },
              keyPrefix: 'pp_vax_schedule',
            )),
            const SizedBox(height: 26),

            // ---- the next visit ----
            pregToolPad(ppCareHeading(next == null ? 'Every visit recorded' : 'Next visit')),
            const SizedBox(height: 12),
            if (next != null) ...[
              pregToolPad(Row(children: [
                Expanded(child: _Tile(label: 'Visit', value: next.ageLabel)),
                const SizedBox(width: 10),
                Expanded(
                    child: _Tile(
                        label: store.statusOf(next) == VaxStatus.due ? 'Due since' : 'Due on',
                        value: store.dateLabelFor(next))),
              ])),
              const SizedBox(height: 10),
              pregToolPad(Text(
                  [for (final id in next.vaccineIds) vaccineById(id).shortName].join(', '),
                  style: pvManrope(fontSize: 14, fontWeight: FontWeight.w600, color: p.ink1))),
              const SizedBox(height: 14),
              pregToolPad(PvCommit(
                key: const ValueKey('pp_vax_mark_given'),
                label: 'Mark as given',
                onTap: () => ppVaxMarkGiven(context, next),
              )),
            ] else
              pregToolPad(Text('Nothing due. Your paediatrician will tell you about anything extra.',
                  style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2))),
            const SizedBox(height: 26),

            // ---- every visit ----
            pregToolPad(ppCareHeading('Every visit')),
            const SizedBox(height: 8),
            pregToolPad(PvRowGroup(p: p, children: [
              for (final v in kVaxVisits) _visitRow(context, v, store),
            ])),
            const SizedBox(height: 22),
            pregToolPad(PvSecondary(
              label: 'Doctor-ready record',
              icon: Icons.description_outlined,
              onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
                settings: const RouteSettings(name: 'pp/vaccines/record'),
                builder: (_) => const DoctorRecordScreen(),
              )),
            )),
            const SizedBox(height: 22),
            pregToolPad(Text(
              "Based on the Indian Academy of Paediatrics schedule (2023) and the government's Universal "
              'Immunisation Programme. Your paediatrician may use a different brand or timing; follow them. '
              'A reminder and record, not medical advice.',
              style: pvManrope(fontSize: 12, height: 1.55, color: p.ink3),
            )),
          ],
        );
      },
    );
  }

  Widget _visitRow(BuildContext context, VaxVisit v, VaxStore store) {
    final p = pvStorePalette;
    final done = store.isDone(v.id);
    final optional = store.isOptionalVisit(v);
    final names = [for (final id in v.vaccineIds) vaccineById(id).shortName].join(', ');
    final on = store.givenOn(v.id);
    final String meta;
    if (done) {
      meta = on == null ? 'Given' : 'Given ${_day(on)}';
    } else if (optional) {
      meta = 'Optional';
    } else if (store.statusOf(v) == VaxStatus.due) {
      meta = 'Due';
    } else {
      meta = store.dateLabelFor(v);
    }
    return PvListRow(
      key: ValueKey('pp_vax_row_${v.id}'),
      p: p,
      leading: PvMarkWell(p: p, hue: done ? 140 : 160, size: 40, mark: IntentMark.pillMark),
      title: '${v.ageLabel} visit',
      line: optional ? '$names. Private schedule: ask your paediatrician.' : names,
      lineMaxLines: 2,
      meta: meta,
      onTap: () => _open(context, v),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Container(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(label.toUpperCase(),
            style: pvManrope(fontSize: 11, fontWeight: FontWeight.w700, letterSpacing: 0.8, color: p.ink3)),
        const SizedBox(height: 6),
        Text(value, style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, color: p.ink1)),
      ]),
    );
  }
}

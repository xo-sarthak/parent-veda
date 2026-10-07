// =============================================================================
//  "At this age" — the answers a parent opens the age page for (2026-10-07)
// -----------------------------------------------------------------------------
//  Parenting gap analysis, P1 (Behind · Age by age): "Ours has the warmest
//  writing and the India notes, but no sleep or feeding numbers for the age, no
//  growth ranges, no 'when to worry' on the page, and no sources. Add to every
//  phase page, in this order, under the summary: 1. 'At this age': sleep,
//  feeding ... 2. 'Growing': the WHO range for weight, length and head for that
//  month, with 'Your doctor plots her on her own curve' and a link to Growth
//  journey. 3. 'Call the doctor if' ... 4. 'Where this comes from'."
//
//  The words come from each phase's own sections (written 2026-10-02, filled
//  for this child by `kPhases`); the ranges are computed from the WHO LMS tables
//  (`pp_who_growth_lms.dart`) for this child's exact age and sex, never typed.
//  The range shown is the 3rd to the 97th centile: "most healthy children sit
//  somewhere in here", not a target.
//
//  ⚠️ "CALL THE DOCTOR IF" IS NEVER FOLDED. The full description stays behind a
//  tap; the doctor lines do not (the same rule as every red flag in the app).
//
//  Mobbin: Oura's readiness contributors (a heading, then plain label and value
//  rows on white) for "Growing"; the doctor box is the doors' folded flag row's
//  shape, opened.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_child_profile.dart';
import 'pp_month_notes.dart';
import 'pp_phases_data.dart';
import 'pp_who_growth_lms.dart';

/// The headings `PpAtThisAge` draws itself, so the full description can leave
/// them out instead of saying them twice.
bool ppAtThisAgeOwns(String heading) {
  final h = heading.toLowerCase();
  return h == 'feeding now' || h == 'sleep now' || h == 'when to call the doctor';
}

String? _section(AgePhase p, String heading) {
  for (final s in p.sections) {
    if (s.heading.toLowerCase() == heading) return s.paragraphs.join(' ');
  }
  return null;
}

/// The 3rd to the 97th centile at [months] for [boy]: (low, high).
(double, double) ppWhoRange(WhoIndicator i, bool boy, double months) =>
    (whoValueAt(i, boy, months, -1.881), whoValueAt(i, boy, months, 1.881));

String _r(double v) => v.toStringAsFixed(1);

/// The sources line under every phase. Named bodies only.
const String kPpPhaseSources = 'Where this comes from: growth from the WHO Child Growth Standards; '
    'vaccines from the Indian Academy of Paediatrics and the government\'s immunisation programme; '
    'milestones from the American Academy of Pediatrics and the CDC; newborn care from the Ministry '
    'of Health\'s home-based care guidance. Written by ParentVeda editorial; not yet reviewed by a '
    'paediatrician.';

class PpAtThisAge extends StatelessWidget {
  const PpAtThisAge({super.key, required this.phase, required this.p, required this.onGrowth});
  final AgePhase phase;
  final V2Palette p;
  final VoidCallback onGrowth;

  @override
  Widget build(BuildContext context) {
    final c = ChildProfileStore.instance;
    final months = c.ageInMonths.toDouble().clamp(0.0, kWhoMaxMonths.toDouble());
    final sleep = _section(phase, 'sleep now');
    final feed = _section(phase, 'feeding now');
    final doctor = _section(phase, 'when to call the doctor');
    Widget head(String t) => Text(t,
        style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1));
    Widget para(String label, String text) => Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text.rich(
            TextSpan(children: [
              TextSpan(text: '$label  ', style: const TextStyle(fontWeight: FontWeight.w800)),
              TextSpan(text: text),
            ]),
            style: pvManrope(fontSize: 14, height: 1.55, color: p.ink1),
          ),
        );

    final boys = c.sexGiven ? [c.isBoy] : [false, true];
    Widget rangeRow(String label, WhoIndicator i, String unit) {
      final parts = [
        for (final b in boys)
          () {
            final (lo, hi) = ppWhoRange(i, b, months);
            final who = c.sexGiven ? '' : (b ? 'boys ' : 'girls ');
            return '$who${_r(lo)} to ${_r(hi)} $unit';
          }(),
      ];
      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SizedBox(
            width: 72,
            child: Text(label, style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w700, color: p.ink2)),
          ),
          Expanded(
            child: Text(parts.join(' · '),
                key: ValueKey('pp_age_range_${i.name}'),
                style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
          ),
        ]),
      );
    }

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      if (sleep != null || feed != null) ...[
        head('At this age'),
        const SizedBox(height: 10),
        if (sleep != null) para('Sleep', sleep),
        if (feed != null) para('Feeding', feed),
        const SizedBox(height: 8),
      ],
      head('Growing'),
      const SizedBox(height: 4),
      Text('Most healthy children this age sit somewhere in these ranges.',
          style: pvManrope(fontSize: 13, height: 1.45, color: p.ink2)),
      const SizedBox(height: 10),
      rangeRow('Weight', WhoIndicator.weight, 'kg'),
      rangeRow(months < 24 ? 'Length' : 'Height', WhoIndicator.length, 'cm'),
      if (months <= 24) rangeRow('Head', WhoIndicator.head, 'cm'),
      const SizedBox(height: 4),
      Text('Your doctor plots ${c.nameMid} on ${c.their} own curve; the shape of it matters more than one number.',
          style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink1)),
      const SizedBox(height: 6),
      Align(
        alignment: Alignment.centerLeft,
        child: TextButton(
          key: const ValueKey('pp_age_growth_link'),
          style: TextButton.styleFrom(padding: EdgeInsets.zero, foregroundColor: p.ink1),
          onPressed: onGrowth,
          child: Text('Track growth  →', style: pvManrope(fontSize: 14, fontWeight: FontWeight.w800, color: p.ink1)),
        ),
      ),
      if (doctor != null) ...[
        const SizedBox(height: 14),
        Container(
          key: const ValueKey('pp_age_call_doctor'),
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: p.line),
          ),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Icon(Icons.local_hospital_outlined, size: 20, color: p.ink1),
              const SizedBox(width: 8),
              Expanded(
                child: Text('Call the doctor if',
                    style: pvManrope(fontSize: 15, fontWeight: FontWeight.w800, color: p.ink1)),
              ),
            ]),
            const SizedBox(height: 8),
            Text(doctor, style: pvManrope(fontSize: 14, height: 1.55, color: p.ink1)),
          ]),
        ),
      ],
      const SizedBox(height: 14),
      Text(kPpPhaseSources,
          key: const ValueKey('pp_age_sources'),
          style: pvManrope(fontSize: 12, height: 1.5, color: p.ink2)),
    ]);
  }
}

/// "This month" on the age page, from 12 months to six years: what is new,
/// three things many children do around now, one thing to try, and one call
/// the doctor line (`kPpMonthNotes`). Nothing under one: the phases already
/// change every month in the first year.
class PpThisMonth extends StatelessWidget {
  const PpThisMonth({super.key, required this.note, required this.p});
  final PpMonthNote note;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final body = pvManrope(fontSize: 14, height: 1.55, color: p.ink1);
    return Container(
      key: const ValueKey('pp_this_month'),
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(note.label.toUpperCase(),
            style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.action)),
        const SizedBox(height: 6),
        Text('This month', style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
        const SizedBox(height: 8),
        Text(note.whatsNew, style: body),
        const SizedBox(height: 12),
        Text('Many children, around now', style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, color: p.ink1)),
        const SizedBox(height: 6),
        for (final u in note.usually)
          Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 10),
                child: Container(width: 5, height: 5, decoration: BoxDecoration(color: p.ink1, shape: BoxShape.circle)),
              ),
              Expanded(child: Text(u, style: body)),
            ]),
          ),
        const SizedBox(height: 10),
        Text.rich(
          TextSpan(children: [
            const TextSpan(text: 'Try this  ', style: TextStyle(fontWeight: FontWeight.w800)),
            TextSpan(text: note.tryThis),
          ]),
          style: body,
        ),
        const SizedBox(height: 10),
        Text.rich(
          key: const ValueKey('pp_this_month_call'),
          TextSpan(children: [
            const TextSpan(text: 'Talk to your doctor if  ', style: TextStyle(fontWeight: FontWeight.w800)),
            TextSpan(text: note.callIf),
          ]),
          style: body,
        ),
        const SizedBox(height: 8),
        Text('Every child grows at their own pace. These are ranges, not a test.',
            style: pvManrope(fontSize: 12.5, color: p.ink2)),
      ]),
    );
  }
}

/// The home's "When to call the doctor" (gap analysis P1, Behind · Health,
/// 2026-10-07): "Point the home's 'When to call the doctor' to it", meaning
/// this phase's own lines, then the symptom check for anything else.
Future<void> showPpCallDoctorSheet(BuildContext context,
    {required AgePhase phase, required V2Palette p, required VoidCallback onCheck}) {
  final text = ppFillChild(_section(phase, 'when to call the doctor') ??
      'If your baby seems unwell, or something feels wrong to you, call your doctor.');
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      top: false,
      child: SingleChildScrollView(
        key: const ValueKey('pp_call_doctor_sheet'),
        padding: const EdgeInsets.fromLTRB(20, 18, 20, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('When to call the doctor',
              style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, color: p.ink1)),
          const SizedBox(height: 4),
          Text(phase.ageLabel, style: pvManrope(fontSize: 13, fontWeight: FontWeight.w700, color: p.ink3)),
          const SizedBox(height: 12),
          Text(text, style: pvManrope(fontSize: 14.5, height: 1.6, color: p.ink1)),
          const SizedBox(height: 12),
          Text('In an emergency, call 112 or 108, or go to the nearest hospital.',
              style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, height: 1.5, color: p.ink1)),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              key: const ValueKey('pp_call_doctor_check'),
              onPressed: () {
                Navigator.of(ctx).pop();
                onCheck();
              },
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(999)),
                side: BorderSide(color: p.ink1),
              ),
              child: Text('Check a symptom: is my baby OK?',
                  style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
            ),
          ),
        ]),
      ),
    ),
  );
}

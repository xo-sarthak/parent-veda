// =============================================================================
//  The well-baby visit card on the age page (2026-10-07)
// -----------------------------------------------------------------------------
//  Gap analysis P2 (Behind · Health & safety): "Add one card per visit on the
//  phase page: 'The 6 week visit: what happens, the vaccines, three questions
//  to ask'."
//
//  Shown on the home when this child's next visit is due, or within three
//  weeks. The vaccines come from the child's own schedule (VaxStore, which
//  follows the schedule she chose); the notes below say what usually happens
//  and three questions worth asking. General, never a dose, and always "your
//  paediatrician will tell you".
//  REQUIRED_REVIEW (paediatrician): every line in kPpVisitNotes.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'pp_child_profile.dart';
import 'pp_vaccine_data.dart';

/// visit id → (what usually happens, three questions to ask).
const Map<String, (String, List<String>)> kPpVisitNotes = {
  'birth': ('Before you leave hospital, your baby is weighed and checked head to toe. The first vaccines are given.',
      ['When should we come back for the first check?', 'Is the jaundice anything to watch?', 'How do I know feeding is going well?']),
  'wk6': ('Weight, length and head are measured, and the doctor checks the hips, eyes and heart. The first big round of vaccines.',
      ['Is the weight gain where it should be?', 'Is the way we feed working?', 'What reaction to the vaccines is normal?']),
  'wk10': ('A shorter visit: a weight check and the second round of vaccines.',
      ['Is the sleep pattern normal for now?', 'Should we start any vitamins?', 'What should we watch for after the shots?']),
  'wk14': ('Growth is checked again and the third round of vaccines is given.',
      ['When do we think about solids?', 'Is the head control on track?', 'What is next on the schedule?']),
  'mo6': ('A growth check, and a good time to talk about starting solids.',
      ['How do we start solids safely?', 'Which foods should wait?', 'Does the baby need iron or other vitamins?']),
  'mo9': ('Growth and development are checked, and the measles vaccine is given.',
      ['Is the sitting and crawling on track?', 'How much milk now that food has started?', 'What should we babyproof first?']),
  'mo12': ('The first birthday check: growth, first steps and first words.',
      ['Is the walking and talking on track?', 'Can we move to the family\'s food?', 'Are the teeth coming in well?']),
  'mo15': ('A visit for growth and the next vaccines.',
      ['How many words is usual now?', 'How do we handle tantrums?', 'Is the sleep normal for this age?']),
  'mo18': ('Boosters are given, and the doctor looks at talking and walking.',
      ['Should we be worried about speech?', 'When should we start potty training?', 'How much screen time is okay?']),
  'yr2': ('A growth check, and a chat about talking, play and eating.',
      ['Is the talking on track?', 'Is picky eating normal?', 'When should the first dental visit be?']),
  'yr5': ('The school-entry check, with the booster vaccines.',
      ['Are the eyes and hearing checked?', 'Is the child ready for school?', 'Which boosters are due now?']),
  'yr10': ('A check-up with the booster for older children.',
      ['Is the growth on track for the age?', 'What changes come with puberty?', 'Are any more vaccines due?']),
};

/// The visit to show, or null when none is due or close.
VaxVisit? ppVisitCardFor({DateTime? now}) {
  final store = VaxStore.instance;
  final v = store.nextVisit;
  if (v == null || !kPpVisitNotes.containsKey(v.id)) return null;
  final when = ChildProfileStore.instance.dob.add(Duration(days: v.ageDays));
  final days = when.difference(now ?? DateTime.now()).inDays;
  return days <= 21 ? v : null;
}

class PpVisitCard extends StatelessWidget {
  const PpVisitCard({super.key, required this.visit, required this.p, required this.onOpen});
  final VaxVisit visit;
  final V2Palette p;
  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final (what, questions) = kPpVisitNotes[visit.id]!;
    final store = VaxStore.instance;
    final names = [for (final id in visit.vaccineIds) vaccineById(id).shortName].join(', ');
    final body = pvManrope(fontSize: 14, height: 1.55, color: p.ink1);
    return Material(
      key: const ValueKey('pp_visit_card'),
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20), side: BorderSide(color: p.line)),
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onOpen,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(store.statusOf(visit) == VaxStatus.due ? 'DUE NOW' : 'COMING UP · ${store.dateLabelFor(visit).toUpperCase()}',
                style: pvManrope(fontSize: 11.5, fontWeight: FontWeight.w800, letterSpacing: 1.4, color: p.action)),
            const SizedBox(height: 6),
            Text('The ${visit.ageLabel} visit',
                style: pvFraunces(fontSize: 19, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
            const SizedBox(height: 8),
            Text(what, style: body),
            const SizedBox(height: 10),
            Text('The vaccines', style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, color: p.ink1)),
            const SizedBox(height: 4),
            Text(names, style: body),
            const SizedBox(height: 10),
            Text('Three questions to ask', style: pvManrope(fontSize: 13.5, fontWeight: FontWeight.w800, color: p.ink1)),
            const SizedBox(height: 4),
            for (final q in questions)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 8, right: 10),
                    child: Container(width: 5, height: 5, decoration: BoxDecoration(color: p.ink1, shape: BoxShape.circle)),
                  ),
                  Expanded(child: Text(q, style: body)),
                ]),
              ),
            const SizedBox(height: 6),
            Text('Your paediatrician will tell you what applies to your child.',
                style: pvManrope(fontSize: 12.5, color: p.ink3)),
          ]),
        ),
      ),
    );
  }
}

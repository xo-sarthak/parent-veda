// =============================================================================
//  "Twins or more" — the promise onboarding makes, now kept (2026-09-30)
// -----------------------------------------------------------------------------
//  From the pregnancy gap analysis, "Make the twins promise true" (P2):
//  onboarding says "Expecting twins or more? You can say so later." and nothing
//  in the app recorded it. What to Expect has an "I'm Having Twins" switch in
//  Pregnancy Details and Flo has "Number of children: 1 / 2 or more".
//
//  ⚠️ ONE FACT, ONE HOME. The answer is `ReadyBirthContextStore.twins`, which the
//  hospital bag's twins switch already wrote and `FamilyProfileStore.expectingTwins`
//  already reads. This sheet is a second way to set the SAME value, not a second
//  value: a mother who says it here finds the bag's switch already on, and the
//  other way round. A new field on the profile would have been two answers to one
//  question, drifting the first time either was edited.
//
//  WHAT SAYING IT CHANGES (ranking and wording, never structure or a clinical
//  fact): the hero's size line says "Each about the size of ...", the week page
//  says "your babies" and adds one line on how twins grow, the Twins and more door
//  leads Learn, and the hospital bag and the profile engine already adapt.
//
//  ⚠️ IT DOES NOT TOUCH HER DUE DATE. What to Expect offers "Re-Calculate Due
//  Date" for twins. We do not: a date from a scan or her doctor is theirs, and a
//  twin pregnancy is often dated by the clinic for reasons we cannot see
//  (CLAUDE.md: a clinic-owned date is not ours to second-guess). The sheet says so.
//
//  ⚠️ NEVER A PERSONAL CHANCE, NEVER THE SEX OF EITHER BABY (PCPNDT Act), as the
//  twins door already holds.
// =============================================================================

import 'package:flutter/material.dart';

import '../../services/ready_birth_context_store.dart';
import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../products/pv_store_chrome.dart' show kPvInk, kPvLine, pvStorePalette;

/// Whether she has said she is carrying more than one. Read at build time by
/// every place the answer changes a word.
bool get pregExpectingTwins => ReadyBirthContextStore.instance.twins;

/// "baby" or "babies".
String pregBabies({bool capital = false}) {
  final w = pregExpectingTwins ? 'babies' : 'baby';
  return capital ? '${w[0].toUpperCase()}${w.substring(1)}' : w;
}

/// The hero's size line for twins: "About the size of a banana" becomes "Each
/// about the size of a banana". Anything else is left as it is.
String pregSizeLineFor(String line) {
  if (!pregExpectingTwins) return line;
  const lead = 'About the size of';
  return line.startsWith(lead) ? 'Each about the size of${line.substring(lead.length)}' : line;
}

/// The one line the week page adds for twins.
const String kPregTwinWeekNote =
    'These are averages for one baby. Twins often grow a little more slowly in the last weeks, '
    'and your scans are the measure of your babies.';

/// What You › Details shows against the row.
String pregTwinsValue() => pregExpectingTwins ? 'Twins or more' : 'One baby';

Future<void> showPregTwinsSheet(BuildContext context) {
  final p = pvStorePalette;
  return showModalBottomSheet<void>(
    context: context,
    backgroundColor: p.ground,
    shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
    builder: (ctx) => SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(22, 22, 22, 20),
        child: AnimatedBuilder(
          animation: ReadyBirthContextStore.instance,
          builder: (_, _) => Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            Semantics(
              header: true,
              child: Text('Carrying more than one?',
                  style: pvFraunces(fontSize: 22, fontWeight: FontWeight.w600, height: 1.2, color: p.ink1)),
            ),
            const SizedBox(height: 8),
            Text(
                'Tell us and your weeks will say so, and the pieces for twins lead for you. '
                'Your due date stays as your doctor or your scan gave it.',
                style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
            const SizedBox(height: 16),
            _Choice(
              key: const ValueKey('twins_one'),
              label: 'One baby',
              selected: !pregExpectingTwins,
              onTap: () => _set(false),
            ),
            const SizedBox(height: 8),
            _Choice(
              key: const ValueKey('twins_more'),
              label: 'Twins or more',
              selected: pregExpectingTwins,
              onTap: () => _set(true),
            ),
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                key: const ValueKey('twins_done'),
                onPressed: () => Navigator.of(ctx).pop(),
                child: Text('Done', style: pvManrope(fontSize: 14, fontWeight: FontWeight.w700, color: kPvInk)),
              ),
            ),
          ]),
        ),
      ),
    ),
  );
}

void _set(bool twins) {
  pvCommitFeedback();
  ReadyBirthContextStore.instance.setTwins(twins);
}

class _Choice extends StatelessWidget {
  const _Choice({super.key, required this.label, required this.selected, required this.onTap});
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: selected ? kPvInk : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: selected ? kPvInk : kPvLine),
            ),
            child: Text(label,
                style: pvManrope(
                    fontSize: 15, fontWeight: FontWeight.w700, color: selected ? Colors.white : kPvInk)),
          ),
        ),
      );
}

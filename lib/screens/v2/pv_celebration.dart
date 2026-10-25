// =============================================================================
//  The celebration page: a move between stages, marked calmly
//  (2026-10-25, STAGE-TRANSITIONS F4)
// -----------------------------------------------------------------------------
//  The user's choice (2026-10-25): "Calm: painting, line, button" for every
//  move, no confetti. A painting, the name, one warm line, what changes and
//  what does not, and one ink button. Mobbin: Alan's and Headway's "You did
//  it" pages, in our look (white ground, Fraunces title, the one ink pill).
//
//  Three moves, three callers:
//    * the positive test keeps its own page, "A beautiful new chapter begins"
//      (ttc_transition_screen.dart), rebuilt after the 10-22 walk and kept on
//      the user's word (2026-10-25);
//    * the birth: [openBirthCelebration], after "Baby has arrived";
//    * turning six: sk_turning_six.dart, before the grown-up gate.
//
//  ⚠️ IT SAYS WHAT STAYS. Every move here is one a family fears losing
//  something in, so the lines name what is kept ("Your pregnancy is kept"),
//  the same promise the transition page proves with counts.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../widgets/pv_feedback.dart';
import '../post_pregnancy/phase_map_screen.dart' show PhasePainting;
import '../post_pregnancy/pp_child_profile.dart';
import '../post_pregnancy/pp_phases_data.dart' show kPhases;
import 'v2_palette.dart';

const String kPvCelebrationRoute = 'celebration';

class PvCelebrationScreen extends StatelessWidget {
  const PvCelebrationScreen({
    super.key,
    required this.painting,
    required this.title,
    required this.line,
    required this.changes,
    required this.primary,
    required this.onPrimary,
    this.secondary,
    this.onSecondary,
  });

  final Widget painting;
  final String title;
  final String line;

  /// What changes and what stays, three short lines at most.
  final List<String> changes;
  final String primary;
  final void Function(BuildContext context) onPrimary;
  final String? secondary;
  final void Function(BuildContext context)? onSecondary;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, box) => SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: box.maxHeight - 40),
              child: IntrinsicHeight(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(26),
                    child: AspectRatio(aspectRatio: 1 / 0.9, child: painting),
                  ),
                  const SizedBox(height: 24),
                  Text(title,
                      key: const ValueKey('pv_celebration_title'),
                      style: pvFraunces(fontSize: 32, fontWeight: FontWeight.w600, height: 1.15, color: p.ink1)),
                  const SizedBox(height: 8),
                  Text(line, style: pvManrope(fontSize: 15.5, height: 1.55, color: p.ink2)),
                  const SizedBox(height: 18),
                  for (final c in changes)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 1),
                          child: Icon(Icons.check_rounded, size: 18, color: p.ink1),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(c, style: pvManrope(fontSize: 14, height: 1.45, color: p.ink1)),
                        ),
                      ]),
                    ),
                  const Spacer(),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: FilledButton(
                      key: const ValueKey('pv_celebration_primary'),
                      style: FilledButton.styleFrom(
                        backgroundColor: const Color(0xFF2F2C30), // the one ink
                        foregroundColor: Colors.white,
                        shape: const StadiumBorder(),
                      ),
                      onPressed: () {
                        pvCommitFeedback();
                        onPrimary(context);
                      },
                      child: Text(primary,
                          style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: Colors.white)),
                    ),
                  ),
                  if (secondary != null) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: OutlinedButton(
                        key: const ValueKey('pv_celebration_secondary'),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: p.ink1,
                          side: BorderSide(color: p.line),
                          shape: const StadiumBorder(),
                        ),
                        onPressed: () {
                          pvCommitFeedback();
                          (onSecondary ?? (c) => Navigator.of(c).maybePop())(context);
                        },
                        child: Text(secondary!,
                            style: pvManrope(fontSize: 15, fontWeight: FontWeight.w700, color: p.ink1)),
                      ),
                    ),
                  ],
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

const _kMonths = [
  'January', 'February', 'March', 'April', 'May', 'June',
  'July', 'August', 'September', 'October', 'November', 'December',
];

/// The birth page's words, pure so the tests read them. [olderNames] are the
/// children she already has, whose homes stay as they are.
@visibleForTesting
({String title, String line, List<String> changes, String primary}) birthCelebrationWords({
  required String name,
  required DateTime dob,
  List<String> olderNames = const [],
}) {
  final named = name.trim().isNotEmpty && name != Child.placeholder;
  final who = named ? name.trim() : 'your baby';
  return (
    title: named ? 'Welcome, $who' : 'Welcome, little one',
    line: 'Born ${dob.day} ${_kMonths[dob.month - 1]}. Rest when you can; the rest can wait.',
    changes: [
      named ? '$who has a home and records of their own now' : 'Your baby has a home and records of their own now',
      'Your pregnancy is kept: photos, letters, journal',
      if (olderNames.length == 1)
        "${olderNames.first}'s home stays exactly as it is"
      else if (olderNames.length > 1)
        "Your other children's homes stay exactly as they are",
    ],
    primary: named ? "Open $who's home" : "Open your baby's home",
  );
}

/// After "Baby has arrived" (You, and the arrival card): the birth page,
/// then [then] (opening the parenting home). The child just added is the
/// active one. Back from the page does the same as its button: the move has
/// happened either way, so there is nowhere else to go.
Future<void> openBirthCelebration(BuildContext context, {required void Function(BuildContext) then}) async {
  final kids = ChildProfileStore.instance;
  final baby = kids.active;
  final words = birthCelebrationWords(
    name: baby.name,
    dob: baby.dob,
    olderNames: [
      for (final c in kids.children)
        if (c.id != baby.id && c.name != Child.placeholder) c.name,
    ],
  );
  var done = false;
  void go(BuildContext c) {
    if (done) return;
    done = true;
    Navigator.of(c).pop();
  }

  await Navigator.of(context).push(MaterialPageRoute<void>(
    settings: const RouteSettings(name: kPvCelebrationRoute),
    builder: (_) => PvCelebrationScreen(
      painting: PhasePainting(phase: kPhases.first),
      title: words.title,
      line: words.line,
      changes: words.changes,
      primary: words.primary,
      onPrimary: go,
    ),
  ));
  if (context.mounted) then(context);
}

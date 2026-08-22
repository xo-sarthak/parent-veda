// =============================================================================
//  FindHelpTriageScreen - "Work out which help you need", as questions
// -----------------------------------------------------------------------------
//  ⚠️ THIS EXISTS BECAUSE A LINK PROMISED IT AND A SCREEN DID NOT DELIVER IT.
//
//  `PpLink('Work out which help you need')` on the "something is off and you
//  cannot name it" page carried the blurb "A few questions, then the likely
//  cause and the right kind of expert", and opened `ProblemSolverScreen` — a
//  search box over a Browse-by-need list. No questions, no narrowing. A parent
//  who could not name the problem was handed a field that requires her to name
//  it.
//
//  Reported as: "the work out which help you need is not taking user to a few
//  questions as committed but to browse by need page directly."
//
//  ⚠️ IT ANSWERS "WHICH EXPERT", NEVER "WHAT IS WRONG". The old blurb also
//  promised "the likely cause", and that half was quietly dropped rather than
//  built. Suggesting a cause from three taps is a diagnosis, which this app
//  does not do at any price — see CLAUDE.md. The questions route to a KIND OF
//  PERSON, which is a routing decision and not a clinical one. The blurb now
//  promises only what this screen actually does.
//
//  ⚠️ EVERY PATH ENDS SOMEWHERE REAL. Each answer maps to a `FindHelpNeed` that
//  has experts behind it — checked by `test/pp_consult_filter_test.dart` — and
//  the escape hatch to the full roster is on every screen, because a parent
//  whose answer is not on the list must never be stuck inside a funnel.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_experts_data.dart';
import 'problem_solver_screen.dart';
import 'provider_results_screen.dart';

/// One answer: what it says, and which need it routes to.
///
/// ⚠️ `category` MATCHES `Expert.category`, NOT the display label. The two
/// differ ("Paediatrician" vs "Pediatrician") and matching on the label is how
/// a filter silently returns nobody.
class _Answer {
  const _Answer(this.label, this.hint, this.category);
  final String label;
  final String hint;
  final String category;
}

class FindHelpTriageScreen extends StatefulWidget {
  const FindHelpTriageScreen({super.key});

  @override
  State<FindHelpTriageScreen> createState() => _FindHelpTriageScreenState();
}

class _FindHelpTriageScreenState extends State<FindHelpTriageScreen> {
  /// null = question one, 'child' / 'me' = question two.
  String? _who;

  Widget _pad(Widget c) =>
      Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  // ⚠️ THE OPTIONS ARE BOUNDED BY REAL SUPPLY, NOT BY WHAT WOULD MAKE A TIDY
  // QUIZ. The roster holds seven categories. Offering "sleep" or "nutrition"
  // here — both obvious next questions — would route to nobody, and an empty
  // results list after three taps is worse than the search box this replaced.
  // When supply grows, this list grows with it.
  static const _child = <_Answer>[
    _Answer('Feeding, or breastfeeding', 'Latch, supply, bottles, weaning',
        'Lactation expert'),
    _Answer('Talking, or not talking yet', 'Words, sounds, understanding',
        'Speech therapist'),
    _Answer('Behaviour, mood, or how he is coping',
        'Tantrums, clinginess, big changes', 'Child psychologist'),
    _Answer('His skin', 'A rash that keeps coming back, eczema', 'Child derma'),
    _Answer('How he is developing overall',
        'Milestones, and whether to look further', 'Special needs expert'),
    _Answer('Something else, or you are not sure',
        'Start with the doctor who knows children', 'Pediatrician'),
  ];

  static const _me = <_Answer>[
    _Answer('Feeding him', 'Latch, supply, pain, stopping', 'Lactation expert'),
    _Answer('My own body after birth', 'Bleeding, pain, healing, periods',
        'Gynecologist'),
    _Answer('I do not know where to start', 'See everyone and choose yourself',
        ''),
  ];

  void _open(String category) {
    // An empty category is the honest "just show me everyone" answer.
    if (category.isEmpty) {
      Navigator.of(context).push(MaterialPageRoute<void>(
        settings: const RouteSettings(name: 'pp/find_help'),
        builder: (_) => const ProblemSolverScreen(),
      ));
      return;
    }
    final need = kFindHelpNeeds.firstWhere(
      (n) => n.category == category,
      // ⚠️ FALLS BACK TO THE FULL ROSTER RATHER THAN THROWING. A category that
      // stops matching is a content bug, and a parent must not meet it as a
      // crash. The test names the mismatch in CI instead.
      orElse: () => kFindHelpNeeds.first,
    );
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: RouteSettings(name: 'pp/find_help/$category'),
      builder: (_) => ProviderResultsScreen(need: need),
    ));
  }

  @override
  Widget build(BuildContext context) {
    final answers = _who == null
        ? const <_Answer>[]
        : (_who == 'child' ? _child : _me);

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 48),
          children: [
            _pad(_who == null
                ? ppBack(context, 'Back')
                : GestureDetector(
                    onTap: () => setState(() => _who = null),
                    behavior: HitTestBehavior.opaque,
                    child: Row(children: [
                      const Icon(Icons.arrow_back_rounded,
                          size: 18, color: ppSoft),
                      const SizedBox(width: 8),
                      Text('Back',
                          style:
                              ppBody(13.5, color: ppSoft, w: FontWeight.w700)),
                    ]),
                  )),
            const SizedBox(height: 22),
            _pad(ppEyebrow('Finding the right person', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text(
                _who == null
                    ? 'Who is this about?'
                    : 'What is it mostly about?',
                style: ppFraunces(28, h: 1.12))),
            const SizedBox(height: 8),
            _pad(Text(
                _who == null
                    ? 'Two questions, then the right kind of expert. We will '
                        'not tell you what is wrong, only who is best placed '
                        'to look.'
                    : 'Pick the closest one. Nothing here is a diagnosis, and '
                        'you can change your mind on the next screen.',
                style: ppBody(14, h: 1.55))),
            const SizedBox(height: 24),

            if (_who == null) ...[
              _pad(_option('My child', 'Anything about him',
                  () => setState(() => _who = 'child'))),
              const SizedBox(height: 10),
              _pad(_option('Me', 'How I am doing, or feeding him',
                  () => setState(() => _who = 'me'))),
            ] else
              for (final a in answers) ...[
                _pad(_option(a.label, a.hint, () => _open(a.category))),
                const SizedBox(height: 10),
              ],

            const SizedBox(height: 14),
            // The way out, on every screen.
            _pad(GestureDetector(
              onTap: () => _open(''),
              behavior: HitTestBehavior.opaque,
              child: Text('Or see every expert and choose yourself',
                  style: ppBody(13, color: ppMuted, w: FontWeight.w700)),
            )),
          ],
        ),
      ),
    );
  }

  Widget _option(String label, String hint, VoidCallback onTap) =>
      GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 15, 13, 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: ppHair),
          ),
          child: Row(children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(label, style: ppFraunces(16.5, h: 1.2)),
                  const SizedBox(height: 4),
                  Text(hint, style: ppBody(12.5, color: ppMuted, h: 1.45)),
                ],
              ),
            ),
            const SizedBox(width: 10),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppSoft),
          ]),
        ),
      );
}

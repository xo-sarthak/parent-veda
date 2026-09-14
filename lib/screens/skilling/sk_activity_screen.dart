// =============================================================================
//  SkActivityScreen — one activity, done, then honestly named
// -----------------------------------------------------------------------------
//  The brief's shape, screen by screen: "The child just plays. At the end,
//  one honest line tells her what she practised ('you just got good at
//  spotting the step that was wrong'), and the parent note explains, in
//  plain words with no hype, why that is a real thinking skill worth
//  building. No score, no 'genius', no claim she is ahead."
//
//  So the screen is: the title and the one warm line, what you need, the
//  steps (big, numbered, read aloud), and then THREE BUTTONS that are the
//  whole of the keepsake's vocabulary — I tried it · I did it again · I made
//  something. Tapping one writes a WORD to `SkPracticeStore` and reveals
//  `whatYouPractised`. Nothing counts, nothing fills, nothing unlocks.
//
//  ⚠️ `theThinking` IS FOR THE PARENT AND IS BEHIND THE GATE. The task PDFs
//  are explicit: "kept out of the kid flow, shown on a parent tap." It is
//  the last thing on the page, as a "For the grown-up" row that asks the
//  grown-up check and then shows the line in a sheet.
//
//  ⚠️ NO TIMER. "No timer used as competition" is a hard rule in every task
//  PDF, and the only timer that is not a competition is one the child
//  cannot see. So there is none.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'sk_content.dart';
import 'sk_door_content.dart';
import 'sk_practice_store.dart';

class SkActivityScreen extends StatelessWidget {
  const SkActivityScreen({
    super.key,
    required this.content,
    required this.activity,
  });

  final SkDoorContent content;
  final SkActivity activity;

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
        animation: Listenable.merge(
            [V2PaletteStore.instance, SkPracticeStore.instance]),
        builder: (context, _) =>
            _body(context, V2PaletteStore.instance.current),
      );

  Widget _body(BuildContext context, V2Palette p) {
    final a = activity;
    final skill = content.skillById(a.skillPurpose);
    final word = SkPracticeStore.instance.wordFor(content.doorId, a.id);
    final done = word.isNotEmpty;

    return Scaffold(
      backgroundColor: p.ground,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 48),
          children: [
            Row(children: [
              skBack(context, p),
              const Spacer(),
              SkReadAloud(
                  text: a.spokenText,
                  cardKey: 'sk/${content.doorId}/${a.id}'),
            ]),
            const SizedBox(height: 18),

            // The skill it builds, named quietly, above the title.
            if (skill != null)
              Text(skill.label.toUpperCase(),
                  style: pvManrope(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: p.action)),
            const SizedBox(height: 8),
            Text(a.title,
                style: pvFraunces(
                    fontSize: 30,
                    fontWeight: FontWeight.w600,
                    height: 1.18,
                    color: p.ink1)),
            if (a.oneLine.isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(a.oneLine,
                  style: pvManrope(
                      fontSize: 19,
                      fontWeight: FontWeight.w500,
                      height: 1.5,
                      color: p.ink1)),
            ],
            if (a.tool != null || a.withGrownUp || a.multiSession) ...[
              const SizedBox(height: 12),
              Wrap(spacing: 6, runSpacing: 6, children: [
                if (a.tool != null)
                  _Chip(label: a.tool!, icon: Icons.computer_outlined, p: p),
                // The 11 to 14 task: AI-literacy projects are marked "with a
                // grown-up"; projects that span sittings say so.
                if (a.withGrownUp)
                  _Chip(
                      label: 'With a grown-up',
                      icon: Icons.family_restroom_outlined,
                      p: p),
                if (a.multiSession)
                  _Chip(
                      label: 'More than one sitting',
                      icon: Icons.event_repeat_outlined,
                      p: p),
              ]),
            ],
            const SizedBox(height: 24),

            if (a.materials.isNotEmpty) ...[
              _Heading('What you need', p),
              const SizedBox(height: 8),
              Text(a.materials,
                  style: pvManrope(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      height: 1.55,
                      color: p.ink2)),
              const SizedBox(height: 26),
            ],

            if (a.steps.isNotEmpty) ...[
              _Heading('What to do', p),
              const SizedBox(height: 14),
              for (final (i, s) in a.steps.indexed) ...[
                skStepRow(i, s, null, p),
                if (i != a.steps.length - 1) const SizedBox(height: 18),
              ],
              const SizedBox(height: 30),
            ],

            // ---- the three words --------------------------------------------
            _Heading(done ? 'You did it' : 'When you are done', p),
            const SizedBox(height: 12),
            for (final k in SkPractice.values) ...[
              _WordButton(
                key: Key('sk-practice-${k.name}'),
                label: switch (k) {
                  SkPractice.tried => 'I tried it',
                  SkPractice.practisedAgain => 'I did it again',
                  SkPractice.made => 'I made something',
                },
                icon: switch (k) {
                  SkPractice.tried => Icons.check_rounded,
                  SkPractice.practisedAgain => Icons.replay_rounded,
                  SkPractice.made => Icons.auto_awesome_outlined,
                },
                p: p,
                onTap: () => SkPracticeStore.instance.record(
                  doorId: content.doorId,
                  itemId: a.id,
                  title: a.title,
                  kind: k,
                ),
              ),
              const SizedBox(height: 10),
            ],

            // ---- the honest end line, once she has done it ---------------
            if (done) ...[
              const SizedBox(height: 14),
              Container(
                key: const Key('sk-what-you-practised'),
                padding: const EdgeInsets.fromLTRB(18, 16, 18, 18),
                decoration: BoxDecoration(
                  color: v2BlockTint(128, p),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('WHAT YOU PRACTISED  ·  ${word.toUpperCase()}',
                          style: pvManrope(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.1,
                              color: p.ink2)),
                      const SizedBox(height: 8),
                      Text(
                          a.whatYouPractised.isEmpty
                              ? 'You practised ${skill?.label.toLowerCase() ?? 'a real thinking skill'}. Nice work.'
                              : a.whatYouPractised,
                          style: pvFraunces(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              height: 1.3,
                              color: p.ink1)),
                    ]),
              ),
            ],
            const SizedBox(height: 28),

            // ---- for the grown-up, behind the gate -----------------------
            SkGrownUpButton(
              label: 'For the grown-up: why this is a real skill',
              onPassed: () => skShowGrownUpSheet(context,
                  title: 'The thinking', body: a.theThinking),
            ),
          ],
        ),
      ),
    );
  }
}

class _Heading extends StatelessWidget {
  const _Heading(this.text, this.p);
  final String text;
  final V2Palette p;
  @override
  Widget build(BuildContext context) => Text(text,
      style: pvFraunces(
          fontSize: 21,
          fontWeight: FontWeight.w600,
          height: 1.22,
          color: p.ink1));
}

class _Chip extends StatelessWidget {
  const _Chip({required this.label, required this.icon, required this.p});
  final String label;
  final IconData icon;
  final V2Palette p;
  // ⚠️ A CHIP THAT WRAPS. The tool line the tasks write can be long
  // ("Scratch, or ScratchJr (parent loads the broken script from setup)"),
  // and a one-line Row overflowed by 37px on a phone (2026-09-14). The icon
  // rides inside the text as a span, so the pill wraps as one paragraph
  // instead of clipping.
  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Text.rich(
          TextSpan(children: [
            WidgetSpan(
              alignment: PlaceholderAlignment.middle,
              child: Padding(
                padding: const EdgeInsets.only(right: 5),
                child: Icon(icon, size: 13, color: p.ink2),
              ),
            ),
            TextSpan(text: label),
          ]),
          style: pvManrope(
              fontSize: 11.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              height: 1.4,
              color: p.ink2),
        ),
      );
}

/// One of the three. Full width, the child tap height, a word and a mark.
class _WordButton extends StatelessWidget {
  const _WordButton({
    super.key,
    required this.label,
    required this.icon,
    required this.p,
    required this.onTap,
  });
  final String label;
  final IconData icon;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            height: kSkTap + 4,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.line),
            ),
            child: Row(children: [
              Icon(icon, size: 22, color: p.action),
              const SizedBox(width: 12),
              Text(label,
                  style: pvManrope(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: p.ink1)),
            ]),
          ),
        ),
      );
}

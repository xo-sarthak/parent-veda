// =============================================================================
//  SkillingPreview — the fourth stage's home, as a DESIGN PREVIEW
// -----------------------------------------------------------------------------
//  ⚠️ THIS IS UI ONLY. NOTHING BEHIND IT IS BUILT, AND NOTHING HERE PRETENDS
//  OTHERWISE.
//
//  Asked for explicitly: the look of the skilling stage, without functionality
//  or wiring. So the file is deliberately shaped to make that impossible to
//  forget six weeks from now:
//
//    · It is called a PREVIEW, not a home. `SkillingHomeV3` would have been the
//      symmetrical name and would have been a lie — the other three V3 homes
//      open real screens.
//    · It is reached only behind `kDebugMode`, from the Explore drawer, beside
//      the Brand Studio debug row that set the precedent.
//    · The doors open a SHEET SHOWING THE PLAN, not a bracket screen. A bracket
//      screen with zero live layers renders a header and nothing — twelve doors
//      onto twelve empty rooms, which is worse than no doors. An empty room read
//      as a promise is what makes an app feel abandoned.
//    · The banner at the top says all of that in one line, on screen, where a
//      reviewer sees it rather than where a developer reads it.
//
//  ---------------------------------------------------------------------------
//  ⚠️ WHY THE HERO CANNOT BE THE COMPASS YET
//  ---------------------------------------------------------------------------
//
//  The workbook's L3 spine for this stage is the **child capability profile —
//  "the compass"**: where the child stands across skills, and what to do next.
//  Every other stage's hero shows a position on its spine, so the symmetrical
//  move is to show a position on this one.
//
//  We cannot, and the reason is not that the data is missing — it is that the
//  obvious rendering is banned. "Where the child stands across twelve skills"
//  drawn as filled arcs, a radar chart or a set of bars **is a score for a
//  child**, and this product does not give children scores. The parenting
//  Development area already refused a progress bar for exactly this, and its
//  door mark had to be redrawn from a bar chart to stepping stones.
//
//  So the compass here is drawn UNFILLED: twelve points, evenly spaced, none
//  emphasised. It says "twelve things, and we are not ranking your child in
//  them" — which happens to be both the honest pre-content state AND, I think,
//  the right long-term answer. The alternative that stays honest once data
//  exists is to mark which skills have been PRACTISED recently, never how well.
//
//  That is a product decision and it is flagged, not taken.
// =============================================================================

import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../models/bracket.dart';
import '../../services/bracket_resolver.dart';
import '../../services/life_stage_store.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_block_grid.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_hero_field.dart';
import '../v2/v3_skill_art.dart';

class SkillingPreviewScreen extends StatelessWidget {
  const SkillingPreviewScreen({super.key, this.lang = AppLanguage.english});

  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final brackets = bracketsFor(LifeStage.skilling);
    // The stage's own accent. Indigo rather than a borrowed stage colour: the
    // other three run rose (TTC), violet (pregnancy) and the phase hue
    // (parenting), and a fourth stage arriving in one of those would read as a
    // section of that stage rather than as its own place.
    final accent = v2BlockTint(258, p);

    return Scaffold(
      backgroundColor: p.ground,
      body: Stack(children: [
        // Same structure as parenting and TTC: the field is the PAGE's surface
        // and does not scroll; the content sheet slides over it.
        Positioned.fill(
          child: V3HeroField(accent: accent, ground: p.ground, variant: 3),
        ),
        ListView(padding: EdgeInsets.zero, children: [
          _Hero(p: p, count: brackets.length),
          _Sheet(p: p, children: [
            const SizedBox(height: 22),
            _pad(_PreviewBanner(p: p)),
            const SizedBox(height: 26),

            _pad(_Head(
                eyebrow: 'Where to go',
                title: 'Twelve things worth getting good at',
                p: p)),
            const SizedBox(height: 14),
            _pad(V2BlockGrid(
              palette: p,
              columns: 4,
              blocks: [
                for (final b in brackets)
                  V2Block(
                    label: b.label.of(lang),
                    icon: Icons.circle_outlined,
                    tint: v2BlockTint(b.hue, p),
                    // ⚠️ `skillMark`, a separate slot from `bracketMark`. The
                    // grid takes either; passing a SkillMark through the
                    // bracket slot would have meant one enum with 29 cases and
                    // a switch that no stage reads in full.
                    skillMark: skillMarkFor(b.id),
                    onTap: () => _showPlan(context, b, p),
                  ),
              ],
            )),
            const SizedBox(height: 32),

            // ---- THE SPINE, AS A STATEMENT RATHER THAN A FEATURE -----------
            _pad(_Head(
                eyebrow: 'The spine',
                title: 'The compass',
                p: p)),
            const SizedBox(height: 12),
            _pad(_CompassCard(p: p, brackets: brackets, lang: lang)),
            const SizedBox(height: 32),

            _pad(_Head(
                eyebrow: 'Open questions',
                title: 'Two things to decide first',
                p: p)),
            const SizedBox(height: 12),
            _pad(_QuestionCard(
              p: p,
              n: '1',
              title: 'Who does this stage talk to?',
              body: 'The workbook says skilling "speaks to the child". Every '
                  'other stage speaks to the parent, and so does every '
                  'disclaimer, consent screen and safety line in the app. '
                  'Addressing a child is a product decision, not a change of '
                  'tone — this shell is written to the parent until it is made.',
            )),
            const SizedBox(height: 12),
            _pad(_QuestionCard(
              p: p,
              n: '2',
              title: 'Do we score children here?',
              body: 'The workbook asks for challenges, streaks, certificates '
                  'and progress reports on almost every bracket. The product '
                  'refuses to score a child anywhere else — Development shows '
                  'the word "Practising", never a percentage. Both cannot be '
                  'true, and nothing is built either way yet.',
            )),
            const SizedBox(height: 32),
          ]),
        ]),
      ]),
    );
  }

  /// What a door does, in place of opening a bracket screen it cannot fill.
  ///
  /// It shows the workbook's own plan for that bracket, layer by layer. That is
  /// not a feature pretending to be one — it is the preview being useful: a
  /// reviewer can tap a door and see exactly what was intended behind it,
  /// which is the question a design preview exists to answer.
  void _showPlan(BuildContext context, Bracket b, V2Palette p) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: p.ground,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (_) => _PlanSheet(bracket: b, p: p, lang: lang),
    );
  }
}

Widget _pad(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: child);

// -----------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero({required this.p, required this.count});

  final V2Palette p;
  final int count;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 288,
        child: SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(22, 18, 22, 22),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ink2 on the tinted field, as everywhere else — a grey
                // calibrated for a neutral ground loses contrast on a
                // chromatic one faster than it loses lightness.
                Text('SKILLING  ·  DESIGN PREVIEW',
                    style: pvManrope(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                        color: p.ink2)),
                const SizedBox(height: 10),
                // ⚠️ THE BIG FACT IS A COUNT, NOT A MEASUREMENT. Every other
                // stage's hero carries a number about the child — a week, an
                // age, a cycle day. The only honest number here is how many
                // skills the stage covers, because nothing about any child has
                // been recorded and the alternative big numbers are all scores.
                Text('$count skills',
                    style: pvFraunces(
                        fontSize: 42,
                        fontWeight: FontWeight.w600,
                        height: 1.05,
                        letterSpacing: -1.3,
                        color: p.ink1)),
                const SizedBox(height: 3),
                Text('Nothing measured. Nothing ranked.',
                    style: pvManrope(
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.3,
                        color: p.ink2)),
                const SizedBox(height: 12),
                Text(
                    'Twelve things a child can get better at, and a place to '
                    'practise each one.',
                    style: pvManrope(
                        fontSize: 13.5, height: 1.45, color: p.ink2)),
              ],
            ),
          ),
        ),
      );
}

class _Sheet extends StatelessWidget {
  const _Sheet({required this.p, required this.children});

  final V2Palette p;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
        // The sheet owns the bottom clearance. Once the background belongs to
        // the page, every piece of scroll-view padding is a window onto it.
        constraints: BoxConstraints(
            minHeight: MediaQuery.sizeOf(context).height * 0.72),
        decoration: BoxDecoration(
          color: p.ground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.10),
              blurRadius: 24,
              offset: const Offset(0, -6),
            ),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ...children,
          const SizedBox(height: 60),
        ]),
      );
}

/// The line that stops this screen being mistaken for a shipped stage.
///
/// On screen rather than in a comment, deliberately. A preview that looks
/// finished gets reported as finished — and the whole reason skilling has no
/// doors into real screens is that looking finished is exactly the failure.
class _PreviewBanner extends StatelessWidget {
  const _PreviewBanner({required this.p});

  final V2Palette p;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
        decoration: BoxDecoration(
          color: p.surfaceAlt,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Icon(Icons.info_outline_rounded, size: 17, color: p.ink2),
          const SizedBox(width: 9),
          Expanded(
            child: Text(
                'Design preview. None of these doors opens anything yet — '
                'tapping one shows what is planned behind it.',
                style:
                    pvManrope(fontSize: 12.5, height: 1.45, color: p.ink2)),
          ),
        ]),
      );
}

class _Head extends StatelessWidget {
  const _Head({required this.eyebrow, required this.title, required this.p});

  final String eyebrow;
  final String title;
  final V2Palette p;

  @override
  Widget build(BuildContext context) =>
      Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ⚠️ `p.action`, NOT `p.ink3` — the section eyebrow is PURPLE on every
        // other V3 screen, and this copy of `_Head` shipped grey.
        //
        // The mechanism is worth naming because it will happen again: the
        // shape was copied from pregnancy and parenting by hand, and one
        // colour token drifted in the copying. Nothing failed — grey is a
        // legal colour, the layout is identical, and no test looks at a
        // Color. It is only visible by putting the three screens side by side,
        // which is exactly what a copied widget makes nobody do.
        //
        // The real fix is a shared `_Head`; it is not shared today because the
        // three take different label types. Until then this comment is the
        // guard.
        Text(eyebrow.toUpperCase(),
            style: pvManrope(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                letterSpacing: 1.4,
                color: p.action)),
        const SizedBox(height: 5),
        Text(title,
            style: pvFraunces(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                height: 1.2,
                letterSpacing: -0.5,
                color: p.ink1)),
      ]);
}

/// The compass, drawn UNFILLED.
///
/// See the file header. Twelve points evenly spaced, each in its bracket's own
/// hue, none emphasised and none connected into a filled polygon — because a
/// filled polygon across a child's abilities is a radar chart, and a radar chart
/// is a score with better manners.
class _CompassCard extends StatelessWidget {
  const _CompassCard(
      {required this.p, required this.brackets, required this.lang});

  final V2Palette p;
  final List<Bracket> brackets;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(18, 18, 18, 18),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: SizedBox(
              width: 168,
              height: 168,
              child: CustomPaint(
                painter: _CompassPainter(
                  hues: [for (final b in brackets) b.hue],
                  ring: p.line,
                  ink: p.ink3,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
              'The workbook puts a "child capability profile" at the centre of '
              'this stage — where the child stands, and what to practise next.',
              style: pvManrope(fontSize: 13.5, height: 1.5, color: p.ink2)),
          const SizedBox(height: 8),
          Text(
              'Drawn empty on purpose. Filling these arcs by ability would be a '
              'score, and this app does not score children. What it can honestly '
              'show later is which skills have been practised — never how well.',
              style: pvManrope(fontSize: 13, height: 1.5, color: p.ink3)),
        ]),
      );
}

class _CompassPainter extends CustomPainter {
  _CompassPainter({required this.hues, required this.ring, required this.ink});

  final List<double> hues;
  final Color ring;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final c = Offset(size.width / 2, size.height / 2);
    final r = math.min(size.width, size.height) / 2 - 14;

    // Two faint rings. NOT gradations — there is no scale here, and rings that
    // look like a scale invite someone to plot on them.
    final ringPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = ring;
    canvas.drawCircle(c, r, ringPaint);
    canvas.drawCircle(c, r * 0.55, ringPaint);

    for (var i = 0; i < hues.length; i++) {
      final ang = -math.pi / 2 + (i / hues.length) * math.pi * 2;
      final at = c + Offset(math.cos(ang), math.sin(ang)) * r;
      // A spoke to each point, hairline, so the twelve read as one object
      // rather than as scattered dots.
      canvas.drawLine(
          c + Offset(math.cos(ang), math.sin(ang)) * (r * 0.55), at, ringPaint);
      canvas.drawCircle(
          at,
          6,
          Paint()
            ..color = HSLColor.fromAHSL(1, hues[i], 0.44, 0.62).toColor());
    }
    // The centre: one small dot, the child. Not a score, not a total.
    canvas.drawCircle(c, 4, Paint()..color = ink);
  }

  @override
  bool shouldRepaint(_CompassPainter old) => old.hues != hues;
}

class _QuestionCard extends StatelessWidget {
  const _QuestionCard(
      {required this.p,
      required this.n,
      required this.title,
      required this.body});

  final V2Palette p;
  final String n;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(16, 15, 16, 15),
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: p.line),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 24,
            height: 24,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: p.surfaceAlt, shape: BoxShape.circle),
            child: Text(n,
                style: pvManrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: p.ink2)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title,
                  style: pvFraunces(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w600,
                      height: 1.25,
                      letterSpacing: -0.3,
                      color: p.ink1)),
              const SizedBox(height: 5),
              Text(body,
                  style:
                      pvManrope(fontSize: 13, height: 1.5, color: p.ink2)),
            ]),
          ),
        ]),
      );
}

/// What a door opens: the workbook's plan for that bracket, in its own words.
class _PlanSheet extends StatelessWidget {
  const _PlanSheet(
      {required this.bracket, required this.p, required this.lang});

  final Bracket bracket;
  final V2Palette p;
  final AppLanguage lang;

  static const _order = [
    (BracketLayer.content, 'What this would hold'),
    (BracketLayer.activities, 'What they would do'),
    (BracketLayer.tools, 'What could be tracked'),
    (BracketLayer.extras, 'Beyond the six'),
    (BracketLayer.products, 'Things that help'),
    (BracketLayer.course, 'Learn it properly'),
    (BracketLayer.consult, 'Talk to someone'),
  ];

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(bracket.hue, p);
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 28),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(
            child: Container(
              width: 38,
              height: 4,
              decoration: BoxDecoration(
                  color: p.line, borderRadius: BorderRadius.circular(2)),
            ),
          ),
          const SizedBox(height: 18),
          Row(children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                  color: tint, borderRadius: BorderRadius.circular(16)),
              child: switch (skillMarkFor(bracket.id)) {
                final SkillMark m => V3SkillArt(mark: m, tint: tint),
                null => const SizedBox.shrink(),
              },
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Text(bracket.title.of(lang),
                  style: pvFraunces(
                      fontSize: 21,
                      fontWeight: FontWeight.w600,
                      height: 1.2,
                      letterSpacing: -0.5,
                      color: p.ink1)),
            ),
          ]),
          const SizedBox(height: 12),
          Text(bracket.blurb.of(lang),
              style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
          const SizedBox(height: 20),
          Container(height: 1, color: p.line),
          const SizedBox(height: 16),
          Text('PLANNED  ·  NONE OF IT BUILT',
              style: pvManrope(
                  fontSize: 10.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.3,
                  color: p.ink3)),
          const SizedBox(height: 14),
          for (final (layer, heading) in _order) ...[
            Text(heading,
                style: pvManrope(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                    color: p.ink2)),
            const SizedBox(height: 3),
            // The workbook's own words, verbatim — this is the one place in the
            // app where the raw `reason` string is shown to a human, and it is
            // correct here precisely because the audience is whoever is deciding
            // what to build.
            Text(bracket.layer(layer).reason,
                style: pvManrope(fontSize: 13.5, height: 1.45, color: p.ink1)),
            const SizedBox(height: 14),
          ],
        ]),
      ),
    );
  }
}

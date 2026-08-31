// =============================================================================
//  "Where do I stand" — the flow, and the read it ends on
// -----------------------------------------------------------------------------
//  The logic lives in `lib/ttc/ttc_pcos_stand.dart`, including every rule about
//  what this screen is not allowed to say. Read that file's header first.
//
//  ---------------------------------------------------------------------------
//  ⚠️ ONE SCROLL, NOT A WIZARD
//  ---------------------------------------------------------------------------
//
//  Eight questions is a wizard's natural shape and it is the wrong one here.
//  A stepper hides how much is left, which is precisely what makes a health
//  questionnaire feel like an interrogation — the competitor's version runs to
//  twenty-odd screens and the dread is the point of the complaint about it.
//
//  One scroll shows the whole ask at a glance: eight short cards, visibly
//  finite, skippable in any order, and abandonable without losing anything. It
//  also matches the symptom logger, which is the other place in this stage she
//  answers questions about her own body.
//
//  ⚠️ EVERY QUESTION IS OPTIONAL AND THE RESULT BUILDS WITHOUT ANY OF THEM.
//  A required field on a screen about symptoms is a screen that punishes "I
//  don't know", and "not sure" is the honest answer to at least three of these.
//  `pcosBuildStand` takes a half-filled `PcosStandAnswers` and returns a real
//  read — thinner, but real.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_pcos_stand.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_hero_field.dart';
import 'ttc_common.dart';
import 'ttc_pcos_check_screen.dart' show kPcosHue;
import 'ttc_prepare_screen.dart';

class TtcPcosStandScreen extends StatefulWidget {
  const TtcPcosStandScreen({super.key});

  @override
  State<TtcPcosStandScreen> createState() => _TtcPcosStandScreenState();
}

class _TtcPcosStandScreenState extends State<TtcPcosStandScreen> {
  final _a = PcosStandAnswers();
  late final PcosCycleFacts _facts = pcosCycleFacts();

  @override
  void initState() {
    super.initState();
    // ⚠️ PREFILLED FROM HER LOGS, NOT ASSUMED. The spec asks Q1 to prefill and
    // *confirm* rather than ask cold, which is the "derive, never ask" rule
    // applied to a question we can mostly answer ourselves. The chip is
    // selected but changeable — a prefill she cannot override is a claim, not
    // a convenience.
    _a.cycleLength = _facts.suggestedLength;
  }

  void _set(VoidCallback f) => setState(f);

  /// How many of the eight have an answer. Drives the progress hairline.
  int get _answered => [
        _a.cycleLength,
        _a.longGaps,
        _a.hairChecked ? true : null,
        _a.thinning,
        _a.acne,
        _a.skinDarkening,
        _a.trying,
        _a.family,
      ].where((v) => v != null).length;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final accent = v2BlockTint(kPcosHue, p);

    return Scaffold(
      backgroundColor: p.ground,
      body: Stack(children: [
        // ⚠️ THE V3 FIELD, NOT A FLAT `ttcBg`. Every other screen this tool is
        // reached from — the focus page, the home, the reader — sits on this
        // field with a sheet sliding over it. A questionnaire on a plain white
        // ground reads as a form that belongs to a different app, which is
        // exactly the feeling this flow exists to avoid.
        Positioned.fill(
          child: V3HeroField(
              accent: accent, ground: p.ground, variant: 2),
        ),
        ListView(
          padding: const EdgeInsets.only(bottom: ttcBottomInset),
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RoundClose(p: p),
                      const SizedBox(height: 14),
                      Text('WHERE DO I STAND',
                          style: pvManrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.3,
                              color: p.ink2)),
                      const SizedBox(height: 8),
                      Text('A read of your own pattern.',
                          style: pvFraunces(
                              fontSize: 27,
                              fontWeight: FontWeight.w600,
                              height: 1.18,
                              letterSpacing: -0.5,
                              color: p.ink1)),
                      const SizedBox(height: 10),
                      // ⚠️ THE DISCLAIMER IS IN THE HERO, NOT AT THE FOOT. On a
                      // screen that could be mistaken for a diagnostic quiz,
                      // "this is not a diagnosis" arriving after eight
                      // questions arrives after she has already decided what
                      // the screen is.
                      Text(
                          'No score, no match, no verdict. Just your pattern '
                          'in plain words, and what is worth taking to a '
                          'doctor.',
                          style: pvManrope(
                              fontSize: 13.5, height: 1.6, color: p.ink2)),
                    ]),
              ),
            ),
            _Sheet(p: p, children: [
              const SizedBox(height: 22),

              // ---- what we already know ------------------------------------
              _pad(_FactsCard(facts: _facts, p: p)),
              const SizedBox(height: 20),

              // ⚠️ A PROGRESS HAIRLINE, NOT "3 OF 8". A counter on a health
              // questionnaire is a debt statement — it tells her how much is
              // still owed, and the competitor's twenty-screen version is
              // exactly what that feels like. A filling line answers the same
              // question without putting a number on the remainder, and it
              // moves visibly on every tap, which is the part that reassures.
              _pad(_Progress(done: _answered, total: 8, p: p)),
              const SizedBox(height: 18),

              _pad(_Q(
                n: 1,
                title: 'How long are your cycles usually?',
                note: _facts.suggestedLength == null
                    ? null
                    : 'Filled in from your logs. Change it if that looks '
                        'wrong.',
                p: p,
                child: _Chips<PcosCycleLength>(
                  value: _a.cycleLength,
                  options: const {
                    PcosCycleLength.typical: 'Mostly 21 to 35 days',
                    PcosCycleLength.shorter: 'Often shorter than 21',
                    PcosCycleLength.longer: 'Often longer than 35',
                    PcosCycleLength.notSure: 'Not sure',
                  },
                  onTap: (v) => _set(() => _a.cycleLength = v),
                  p: p,
                ),
              )),

              _pad(_Q(
                n: 2,
                title: 'Have you gone 3 months or more without a period in '
                    'the last year?',
                note: 'Leaving aside pregnancy, breastfeeding or birth '
                    'control.',
                p: p,
                child: _YesNo(
                    value: _a.longGaps,
                    onTap: (v) => _set(() => _a.longGaps = v),
                    p: p),
              )),

              _pad(_Q(
                n: 3,
                title: 'Have you noticed extra hair growth anywhere?',
                note: 'Tap every area that applies.',
                p: p,
                child: _AreaPicker(
                  selected: _a.hairAreas,
                  checked: _a.hairChecked,
                  onToggle: (h) => _set(() {
                    _a.hairChecked = true;
                    _a.hairAreas.contains(h)
                        ? _a.hairAreas.remove(h)
                        : _a.hairAreas.add(h);
                  }),
                  onNone: () => _set(() {
                    _a.hairChecked = true;
                    _a.hairAreas.clear();
                  }),
                  p: p,
                ),
              )),

              _pad(_Q(
                n: 4,
                title: 'Any hair thinning or loss?',
                p: p,
                child: _Degree(
                    value: _a.thinning,
                    onTap: (v) => _set(() => _a.thinning = v),
                    p: p),
              )),

              _pad(_Q(
                n: 5,
                title: 'Acne for 6 months or more that skincare did not fix?',
                p: p,
                child: _Degree(
                    value: _a.acne,
                    onTap: (v) => _set(() => _a.acne = v),
                    p: p),
              )),

              _pad(_Q(
                n: 6,
                title: 'Darker, thicker skin on your neck, armpits or belly?',
                p: p,
                child: _YesNo(
                    value: _a.skinDarkening,
                    onTap: (v) => _set(() => _a.skinDarkening = v),
                    p: p),
              )),

              _pad(_Q(
                n: 7,
                title: 'How long have you been trying?',
                p: p,
                child: _Chips<PcosTrying>(
                  value: _a.trying,
                  options: const {
                    PcosTrying.underSix: 'Less than 6 months',
                    PcosTrying.sixToTwelve: '6 to 12 months',
                    PcosTrying.overAYear: 'More than a year',
                    PcosTrying.notTrying: 'Not trying right now',
                  },
                  onTap: (v) => _set(() => _a.trying = v),
                  p: p,
                ),
              )),

              _pad(_Q(
                n: 8,
                title: 'Has your mother or sister been told they have PCOS?',
                note: 'Optional.',
                p: p,
                child: _Chips<PcosFamily>(
                  value: _a.family,
                  options: const {
                    PcosFamily.yes: 'Yes',
                    PcosFamily.no: 'No',
                    PcosFamily.dontKnow: "Don't know",
                  },
                  onTap: (v) => _set(() => _a.family = v),
                  p: p,
                ),
              )),

              const SizedBox(height: 6),
              _pad(_Primary(
                label: 'See my read',
                onTap: () {
                  // ⚠️ FIRE AND FORGET, LIKE EVERY OTHER WRITE IN THIS APP.
                  // Local-first: the read is built from `_a` in memory and does
                  // not wait on storage, so a slow disk cannot hold up a screen
                  // she has finished answering.
                  _a.writeThrough();
                  Navigator.of(context).push(MaterialPageRoute<void>(
                    settings:
                        const RouteSettings(name: 'ttc/pcos_stand_result'),
                    builder: (_) =>
                        TtcPcosStandResultScreen(result: pcosBuildStand(_a)),
                  ));
                },
              )),
              const SizedBox(height: 14),
              _pad(Text(
                  'You can leave any of these blank. The read just says less.',
                  textAlign: TextAlign.center,
                  style: pvManrope(
                      fontSize: 11.5, height: 1.5, color: p.ink3))),
              const SizedBox(height: 24),
            ]),
          ],
        ),
      ]),
    );
  }
}

/// The one door out of this flow that costs money, and the only one it has.
void _openConsults(BuildContext context) =>
    Navigator.of(context).push(MaterialPageRoute<void>(
      settings: const RouteSettings(name: 'ttc/consults'),
      builder: (_) => const TtcPrepareScreen(onlyCategory: 'consults'),
    ));

Widget _pad(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: child);

/// The sheet every V3 page slides over its field.
class _Sheet extends StatelessWidget {
  const _Sheet({required this.p, required this.children});

  final V2Palette p;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Container(
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
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start, children: children),
      );
}

class _RoundClose extends StatelessWidget {
  const _RoundClose({required this.p});

  final V2Palette p;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: 'Close',
        child: InkWell(
          onTap: () => Navigator.of(context).maybePop(),
          borderRadius: BorderRadius.circular(999),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: p.surface.withValues(alpha: 0.9),
                shape: BoxShape.circle),
            child: Icon(Icons.close_rounded, size: 19, color: p.ink1),
          ),
        ),
      );
}

/// A filling hairline. Not a counter — see the note at its call site.
class _Progress extends StatelessWidget {
  const _Progress({required this.done, required this.total, required this.p});

  final int done;
  final int total;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(done == 0 ? 'EIGHT SHORT QUESTIONS' : 'KEEP GOING',
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.1,
                  color: p.ink3)),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(999),
            child: Stack(children: [
              Container(height: 4, color: p.line),
              // `LayoutBuilder`-free: a fractional box is enough, and it
              // animates without needing the parent's width.
              FractionallySizedBox(
                widthFactor: total == 0 ? 0 : done / total,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 260),
                  curve: Curves.easeOut,
                  height: 4,
                  color: ttcPurple,
                ),
              ),
            ]),
          ),
        ],
      );
}

/// What her logs already say, shown before the first question.
///
/// ⚠️ THIS EXISTS SO THE FLOW DOES NOT ASK WHAT IT ALREADY KNOWS. It is also
/// the honest version of a progress cue: rather than "2 of 8", it says what the
/// app has brought to the conversation, which is the thing that makes a
/// questionnaire feel less like starting from nothing.
class _FactsCard extends StatelessWidget {
  const _FactsCard({required this.facts, required this.p});

  final PcosCycleFacts facts;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final line = switch (facts.regularity) {
      PcosRegularity.regular =>
        'Across ${facts.completedCycles} logged cycles, your dates look steady.',
      PcosRegularity.irregular =>
        'Across ${facts.completedCycles} logged cycles, your dates have varied.',
      PcosRegularity.notEnoughData =>
        'Not much logged yet, so the questions below do more of the work.',
    };

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: v2BlockTint(288, p),
        borderRadius: BorderRadius.circular(ttcCardRadius),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('FROM YOUR LOGS',
            style: pvManrope(
                fontSize: 9.5,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: p.ink2)),
        const SizedBox(height: 8),
        Text(line, style: ttcBody(14, color: ttcTitleInk, h: 1.55)),
        if (facts.hasLongGap) ...[
          const SizedBox(height: 6),
          Text(
              'Your longest gap between periods was ${facts.longestGapDays} '
              'days.',
              style: ttcBody(13.5, color: ttcSoft, h: 1.5)),
        ],
      ]),
    );
  }
}

// -----------------------------------------------------------------------------
//  The result
// -----------------------------------------------------------------------------

class TtcPcosStandResultScreen extends StatelessWidget {
  const TtcPcosStandResultScreen({super.key, required this.result});

  final PcosStandResult result;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final accent = v2BlockTint(kPcosHue, p);

    return Scaffold(
      backgroundColor: p.ground,
      body: Stack(children: [
        Positioned.fill(
          child:
              V3HeroField(accent: accent, ground: p.ground, variant: 3),
        ),
        ListView(
          padding: const EdgeInsets.only(bottom: ttcBottomInset),
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RoundClose(p: p),
                      const SizedBox(height: 14),
                      Text('YOUR READ',
                          style: pvManrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.3,
                              color: p.ink2)),
                      const SizedBox(height: 8),
                      // ⚠️ THIS IS WHERE A MATCH PERCENTAGE WOULD GO, and the
                      // absence is the design. It is the first place the eye
                      // lands on a result screen, so what sits here decides
                      // what the whole flow was. A sentence about what she is
                      // holding, rather than a verdict about her body.
                      Text('Here is what you told us,\nsaid back plainly.',
                          style: pvFraunces(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              letterSpacing: -0.5,
                              color: p.ink1)),
                    ]),
              ),
            ),
            _Sheet(p: p, children: [
              const SizedBox(height: 24),

              _pad(_BlockHead(
                  label: 'What your cycle looks like',
                  mark: _StandMark.cycle,
                  hue: 206,
                  p: p)),
              const SizedBox(height: 10),
              _pad(_Block(text: result.cycleLine, hue: 206, p: p)),

              if (result.noticed.isNotEmpty) ...[
                const SizedBox(height: 26),
                _pad(_BlockHead(
                    label: 'What else you shared',
                    mark: _StandMark.noticed,
                    hue: 42,
                    p: p)),
                const SizedBox(height: 10),
                // ⚠️ ONE CARD PER LINE, NOT A BULLET LIST. Four observations
                // run together as bullets read as a case being assembled;
                // separated, each stays what it is — one thing worth
                // mentioning, with its own edges.
                for (final line in result.noticed) ...[
                  _pad(_Block(text: line, hue: 42, p: p)),
                  const SizedBox(height: 8),
                ],
              ],

              const SizedBox(height: 26),
              _pad(_BlockHead(
                  label: 'What is worth doing next',
                  mark: _StandMark.next,
                  hue: 160,
                  p: p)),
              const SizedBox(height: 10),
              _pad(_Block(text: result.always, hue: 160, p: p)),
              if (result.nudge != null) ...[
                const SizedBox(height: 8),
                // The nudge is the only card on the page that carries a border,
                // and that is the entire escalation this tool is allowed. No
                // red, no icon, no alarm word.
                _pad(_Block(
                    text: result.nudge!, hue: 42, p: p, outlined: true)),
              ],

              const SizedBox(height: 20),
              _pad(_Primary(
                label: 'Talk to a PCOS specialist',
                onTap: () => _openConsults(context),
              )),
              const SizedBox(height: 10),
              _pad(_Secondary(
                label: 'What to take to your doctor',
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        settings:
                            const RouteSettings(name: 'ttc/pcos_checklist'),
                        builder: (_) =>
                            TtcPcosChecklistScreen(result: result))),
              )),

              const SizedBox(height: 22),
              _pad(_PrivacyLine(p: p)),
              const SizedBox(height: 26),
            ]),
          ],
        ),
      ]),
    );
  }
}

/// The appointment-prep summary.
///
/// ⚠️ FRAMED AS HER NOTES, NOT AS OUR FINDINGS. Every label is first person —
/// "my cycle pattern", "what I have noticed" — because the moment it reads as
/// the app's assessment, a doctor is being handed a second opinion from a
/// phone. As her own notes it is exactly what a good appointment starts with.
///
/// ⚠️ AND IT IS DRAWN AS A PIECE OF PAPER, not as another app card. She is
/// going to screenshot this and hold it up in a room. A page-shaped white
/// block with a rule under each label survives that; a rounded tinted card
/// with an app's chrome around it looks like a share graphic.
class TtcPcosChecklistScreen extends StatelessWidget {
  const TtcPcosChecklistScreen({super.key, required this.result});

  final PcosStandResult result;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final accent = v2BlockTint(kPcosHue, p);

    return Scaffold(
      backgroundColor: p.ground,
      body: Stack(children: [
        Positioned.fill(
          child:
              V3HeroField(accent: accent, ground: p.ground, variant: 4),
        ),
        ListView(
          padding: const EdgeInsets.only(bottom: ttcBottomInset),
          children: [
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(18, 4, 18, 18),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _RoundClose(p: p),
                      const SizedBox(height: 14),
                      Text('APPOINTMENT NOTES',
                          style: pvManrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.3,
                              color: p.ink2)),
                      const SizedBox(height: 8),
                      Text('What to take to\nyour doctor.',
                          style: pvFraunces(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              letterSpacing: -0.5,
                              color: p.ink1)),
                      const SizedBox(height: 10),
                      Text('Screenshot this, or read it out. It is four lines.',
                          style: pvManrope(
                              fontSize: 13.5, height: 1.6, color: p.ink2)),
                    ]),
              ),
            ),
            _Sheet(p: p, children: [
              const SizedBox(height: 24),
              _pad(Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
                decoration: BoxDecoration(
                  color: p.surface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: p.line),
                ),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (var i = 0; i < result.checklist.length; i++) ...[
                        if (i > 0) ...[
                          const SizedBox(height: 15),
                          Divider(color: p.line, height: 1),
                          const SizedBox(height: 15),
                        ],
                        Text(result.checklist[i].label.toUpperCase(),
                            style: pvManrope(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.9,
                                color: p.ink3)),
                        const SizedBox(height: 6),
                        Text(result.checklist[i].value,
                            style: pvJakarta(
                                fontSize: 15.5,
                                fontWeight: FontWeight.w600,
                                height: 1.45,
                                color: p.ink1)),
                      ],
                      const SizedBox(height: 18),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(13),
                        decoration: BoxDecoration(
                          color: p.ground,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(kPcosChecklistDisclaimer,
                            style: pvManrope(
                                fontSize: 12.5,
                                height: 1.55,
                                fontWeight: FontWeight.w700,
                                color: p.ink2)),
                      ),
                    ]),
              )),
              const SizedBox(height: 18),
              _pad(_Primary(
                label: 'Talk to a PCOS specialist',
                onTap: () => _openConsults(context),
              )),
              const SizedBox(height: 22),
              _pad(_PrivacyLine(p: p)),
              const SizedBox(height: 26),
            ]),
          ],
        ),
      ]),
    );
  }
}

/// "This stays on your phone. It is not a medical record."
///
/// ⚠️ A COMPONENT BECAUSE IT APPEARS TWICE AND MUST NOT DRIFT. The spec asks
/// for the result to be "stored privately and labelled clearly as not a medical
/// record", and a sentence typed out at two call sites is a sentence that ends
/// up saying two things.
class _PrivacyLine extends StatelessWidget {
  const _PrivacyLine({required this.p});

  final V2Palette p;

  @override
  Widget build(BuildContext context) =>
      Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Icon(Icons.lock_outline_rounded, size: 15, color: p.ink3),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
              'This stays on your phone. It is not a medical record.',
              style:
                  pvManrope(fontSize: 11.5, height: 1.5, color: p.ink3)),
        ),
      ]);
}

/// Which mark a result block carries.
enum _StandMark { cycle, noticed, next }

/// A block heading with its drawn mark.
class _BlockHead extends StatelessWidget {
  const _BlockHead(
      {required this.label,
      required this.mark,
      required this.hue,
      required this.p});

  final String label;
  final _StandMark mark;
  final double hue;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue, p);
    final deep = HSLColor.fromColor(tint)
        .withSaturation(0.45)
        .withLightness(0.38)
        .toColor();
    return Row(children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
        child: CustomPaint(painter: _StandMarkPainter(mark: mark, ink: deep)),
      ),
      const SizedBox(width: 11),
      Expanded(
        child: Text(label,
            style: pvJakarta(
                fontSize: 17, fontWeight: FontWeight.w700, color: p.ink1)),
      ),
    ]);
  }
}

/// Three marks, drawn rather than iconned — same reason as the symptom set.
class _StandMarkPainter extends CustomPainter {
  const _StandMarkPainter({required this.mark, required this.ink});

  final _StandMark mark;
  final Color ink;

  @override
  void paint(Canvas canvas, Size size) {
    final s = size.shortestSide;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final line = Paint()
      ..color = ink
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;
    final fill = Paint()..color = ink;

    switch (mark) {
      // An open ring: a cycle, with the gap saying it is still running.
      case _StandMark.cycle:
        canvas.drawArc(
            Rect.fromCircle(center: Offset(cx, cy), radius: s * 0.28),
            -1.9,
            4.9,
            false,
            line);
        canvas.drawCircle(Offset(cx + s * 0.24, cy - s * 0.15), s * 0.06, fill);
      // Three marks of different weight — things noticed, not a list.
      case _StandMark.noticed:
        for (var i = 0; i < 3; i++) {
          canvas.drawCircle(
              Offset(cx - s * 0.2 + i * s * 0.2, cy), s * 0.06 + i * s * 0.012,
              fill);
        }
      // A step forward.
      case _StandMark.next:
        canvas.drawLine(
            Offset(cx - s * 0.22, cy), Offset(cx + s * 0.18, cy), line);
        canvas.drawPath(
            Path()
              ..moveTo(cx + s * 0.06, cy - s * 0.12)
              ..lineTo(cx + s * 0.2, cy)
              ..lineTo(cx + s * 0.06, cy + s * 0.12),
            line);
    }
  }

  @override
  bool shouldRepaint(_StandMarkPainter old) =>
      old.mark != mark || old.ink != ink;
}

// -----------------------------------------------------------------------------
//  Furniture
// -----------------------------------------------------------------------------

/// One question, as a card with a numbered chip.
///
/// ⚠️ THE NUMBER IS THE POINT OF THE CHIP. Eight unnumbered cards in a scroll
/// read as an undifferentiated wall; numbered, the scroll has a spine and she
/// can see at a glance that question six is nearly the end. It is the same job
/// the progress hairline does, said a second way — and on a long scroll the
/// hairline is off screen most of the time.
class _Q extends StatelessWidget {
  const _Q({
    required this.n,
    required this.title,
    required this.child,
    required this.p,
    this.note,
  });

  final int n;
  final String title;
  final String? note;
  final Widget child;
  final V2Palette p;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(kPcosHue, p);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        // A hairline rather than a shadow: eight stacked shadows on one scroll
        // is a page that looks like it is hovering.
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 22,
            height: 22,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            child: Text('$n',
                style: pvManrope(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    color: p.ink1)),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(title,
                style: pvJakarta(
                    fontSize: 15.5,
                    fontWeight: FontWeight.w700,
                    height: 1.32,
                    color: p.ink1)),
          ),
        ]),
        if (note != null) ...[
          const SizedBox(height: 7),
          Padding(
            padding: const EdgeInsets.only(left: 33),
            child: Text(note!,
                style: pvManrope(
                    fontSize: 12, height: 1.45, color: p.ink3)),
          ),
        ],
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}

/// A single-choice chip set. Generic so the four question shapes share one
/// control rather than four near-identical ones.
class _Chips<T> extends StatelessWidget {
  const _Chips(
      {required this.value,
      required this.options,
      required this.onTap,
      required this.p});

  final T? value;
  final Map<T, String> options;
  final ValueChanged<T> onTap;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final e in options.entries)
            _Pill(
                label: e.value,
                on: value == e.key,
                onTap: () => onTap(e.key),
                p: p),
        ],
      );
}

class _YesNo extends StatelessWidget {
  const _YesNo({required this.value, required this.onTap, required this.p});

  final PcosYesNo? value;
  final ValueChanged<PcosYesNo> onTap;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => _Chips<PcosYesNo>(
        value: value,
        options: const {
          PcosYesNo.yes: 'Yes',
          PcosYesNo.no: 'No',
          PcosYesNo.notSure: 'Not sure',
        },
        onTap: onTap,
        p: p,
      );
}

class _Degree extends StatelessWidget {
  const _Degree({required this.value, required this.onTap, required this.p});

  final PcosDegree? value;
  final ValueChanged<PcosDegree> onTap;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => _Chips<PcosDegree>(
        value: value,
        // ⚠️ "HAVEN'T NOTICED" IS FIRST, NOT LAST. It is the most common answer
        // and putting it at the end of a severity ladder makes the ladder read
        // as the expected shape of the reply.
        options: const {
          PcosDegree.none: "Haven't noticed",
          PcosDegree.mild: 'Mild',
          PcosDegree.moderate: 'Moderate',
          PcosDegree.severe: 'Severe',
        },
        onTap: onTap,
        p: p,
      );
}

/// Multi-select body areas, plus an explicit "haven't noticed".
class _AreaPicker extends StatelessWidget {
  const _AreaPicker({
    required this.selected,
    required this.checked,
    required this.onToggle,
    required this.onNone,
    required this.p,
  });

  final Set<PcosHairArea> selected;
  final bool checked;
  final ValueChanged<PcosHairArea> onToggle;
  final VoidCallback onNone;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          _Pill(
              label: "Haven't noticed",
              on: checked && selected.isEmpty,
              onTap: onNone,
              p: p),
          for (final h in PcosHairArea.values)
            _Pill(
                label: h.label,
                on: selected.contains(h),
                onTap: () => onToggle(h),
                p: p),
        ],
      );
}

class _Pill extends StatelessWidget {
  const _Pill(
      {required this.label,
      required this.on,
      required this.onTap,
      required this.p});

  final String label;
  final bool on;
  final VoidCallback onTap;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 130),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: on ? v2BlockTint(288, p) : ttcPanel,
            borderRadius: BorderRadius.circular(999),
            border: on ? Border.all(color: ttcPurple, width: 1.5) : null,
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 13,
                  fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                  color: ttcTitleInk)),
        ),
      );
}

class _Block extends StatelessWidget {
  const _Block(
      {required this.text,
      required this.hue,
      required this.p,
      this.outlined = false});

  final String text;
  final double hue;
  final V2Palette p;

  /// Used by the nudge, and by nothing else. The entire escalation vocabulary
  /// of this tool is one hairline.
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue, p);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tint,
        borderRadius: BorderRadius.circular(18),
        border: outlined
            ? Border.all(
                color: HSLColor.fromColor(tint)
                    .withSaturation(0.45)
                    .withLightness(0.55)
                    .toColor(),
                width: 1.5)
            : null,
      ),
      child: Text(text,
          style: pvManrope(fontSize: 14.5, height: 1.62, color: p.ink1)),
    );
  }
}

class _Primary extends StatelessWidget {
  const _Primary({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: ttcPurple,
            borderRadius: BorderRadius.circular(999),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: Colors.white)),
        ),
      );
}

class _Secondary extends StatelessWidget {
  const _Secondary({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 15),
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ttcLine),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w800,
                  color: ttcTitleInk)),
        ),
      );
}

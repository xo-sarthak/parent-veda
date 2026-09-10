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
import 'ttc_common.dart';
import 'ttc_tool_chrome.dart';
import 'ttc_pcos_check_screen.dart' show kPcosHue;
import 'ttc_prepare_screen.dart';

class TtcPcosStandScreen extends StatefulWidget {
  const TtcPcosStandScreen({super.key});

  @override
  State<TtcPcosStandScreen> createState() => _TtcPcosStandScreenState();
}

class _TtcPcosStandScreenState extends State<TtcPcosStandScreen> {
  @override
  Widget build(BuildContext context) {
    return const TtcToolScaffold(
      hue: kPcosHue,
      variant: 2,
      eyebrow: kPcosStandEyebrow,
      title: kPcosStandTitle,
      intro: kPcosStandIntro,
      children: [TtcPcosStandBody()],
    );
  }
}

/// The tool's eyebrow, title and its "what this is not" line.
///
/// ⚠️ CONSTANTS BECAUSE TWO SURFACES SAY THEM NOW. The tool has its own screen
/// AND renders inline inside the PCOS door, and the third of these is the
/// sentence that stops the flow reading as a diagnostic quiz. Two typed copies
/// of a safety line become two lines that say different things.
const String kPcosStandEyebrow = 'WHERE DO I STAND';
const String kPcosStandTitle = 'A read of your own pattern.';
const String kPcosStandIntro =
    'No score, no match, no verdict. Just your pattern in plain words, and '
    'what is worth taking to a doctor.';

/// The eight questions and the button, with no frame of their own.
///
/// ⚠️ EXTRACTED SO THE PCOS DOOR CAN SHOW THE TOOL IN PLACE. Selecting "Where
/// do I stand" on that page used to open this screen; it now renders these
/// questions under the selector rail with no navigation at all. What could NOT
/// come with it is the chrome — a close button on a page you did not navigate
/// to is a control that lies about where it goes, and a second hero field under
/// the door's own photograph is two backgrounds arguing.
///
/// ⚠️ THE SPLIT IS FRAME FROM CONTENT, AND NOTHING ELSE MOVED. Same eight
/// questions, same wording, same prefill, same progress hairline, same result.
/// `docs/STILL-OPEN.md` §18.5 says this screen is signed off and must not be
/// redesigned; it has not been. It has been given a second container.
class TtcPcosStandBody extends StatefulWidget {
  const TtcPcosStandBody({super.key});

  @override
  State<TtcPcosStandBody> createState() => _TtcPcosStandBodyState();
}

class _TtcPcosStandBodyState extends State<TtcPcosStandBody> {
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

    return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
              // WARNING: 8, NOT 22. This gap was written when the tool owned a
              // whole screen and had a hero above it. Inline under the door's
              // tab rail it is the second gap in a row, and two gaps read as
              // one large empty band -- "in between the tabs above and the
              // eight short questions, space is being wasted".
              const SizedBox(height: 8),

              // ⚠️ A PROGRESS HAIRLINE, NOT "3 OF 8". A counter on a health
              // questionnaire is a debt statement — it tells her how much is
              // still owed, and the competitor's twenty-screen version is
              // exactly what that feels like. A filling line answers the same
              // question without putting a number on the remainder, and it
              // moves visibly on every tap, which is the part that reassures.
              ttcToolPad(TtcToolProgress(
                  done: _answered,
                  total: 8,
                  startLabel: 'EIGHT SHORT QUESTIONS')),
              const SizedBox(height: 12),

              ttcToolPad(TtcToolQuestion(
                hue: kPcosHue,
                n: 1,
                title: 'How long are your cycles usually?',
                note: _facts.suggestedLength == null
                    ? null
                    : 'Filled in from your logs. Change it if that looks '
                        'wrong.',
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

              ttcToolPad(TtcToolQuestion(
                hue: kPcosHue,
                n: 2,
                title: 'Have you gone 3 months or more without a period in '
                    'the last year?',
                note: 'Leaving aside pregnancy, breastfeeding or birth '
                    'control.',
                child: _YesNo(
                    value: _a.longGaps,
                    onTap: (v) => _set(() => _a.longGaps = v),
                    p: p),
              )),

              ttcToolPad(TtcToolQuestion(
                hue: kPcosHue,
                n: 3,
                title: 'Have you noticed extra hair growth anywhere?',
                note: 'Tap every area that applies.',
                child: _AreaPicker(
                  selected: _a.hairAreas,
                  checked: _a.hairChecked,
                  // ⚠️ THE ONLY QUESTION WHERE DESELECT NEEDED THINKING, because
                  // "answered" here is two fields rather than one. `hairChecked`
                  // means she replied at all; `hairAreas` means where. So
                  // "Haven't noticed" is checked-and-empty, and unticking the
                  // last area has to take `hairChecked` down with it — otherwise
                  // clearing her areas would silently light up "Haven't
                  // noticed", which is a different answer than the one she just
                  // withdrew.
                  onToggle: (h) => _set(() {
                    _a.hairAreas.contains(h)
                        ? _a.hairAreas.remove(h)
                        : _a.hairAreas.add(h);
                    _a.hairChecked = _a.hairAreas.isNotEmpty;
                  }),
                  onNone: () => _set(() {
                    // Tapping it while it is already the answer clears the
                    // question, the same as every other block on the page.
                    final wasNone = _a.hairChecked && _a.hairAreas.isEmpty;
                    _a.hairAreas.clear();
                    _a.hairChecked = !wasNone;
                  }),
                  p: p,
                ),
              )),

              ttcToolPad(TtcToolQuestion(
                hue: kPcosHue,
                n: 4,
                title: 'Any hair thinning or loss?',
                child: _Degree(
                    value: _a.thinning,
                    onTap: (v) => _set(() => _a.thinning = v),
                    p: p),
              )),

              ttcToolPad(TtcToolQuestion(
                hue: kPcosHue,
                n: 5,
                title: 'Acne for 6 months or more that skincare did not fix?',
                child: _Degree(
                    value: _a.acne,
                    onTap: (v) => _set(() => _a.acne = v),
                    p: p),
              )),

              ttcToolPad(TtcToolQuestion(
                hue: kPcosHue,
                n: 6,
                title: 'Darker, thicker skin on your neck, armpits or belly?',
                child: _YesNo(
                    value: _a.skinDarkening,
                    onTap: (v) => _set(() => _a.skinDarkening = v),
                    p: p),
              )),

              ttcToolPad(TtcToolQuestion(
                hue: kPcosHue,
                n: 7,
                title: 'How long have you been trying?',
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

              ttcToolPad(TtcToolQuestion(
                hue: kPcosHue,
                n: 8,
                title: 'Has your mother or sister been told they have PCOS?',
                note: 'Optional.',
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
              _pad(TtcToolPrimary(
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

              // ---- what we already know, AFTER the asking -------------------
              //
              // WARNING: THIS USED TO OPEN THE FLOW AND IT COST TOO MUCH ROOM.
              // The intent was sound — show what the app already knows so the
              // screen does not feel like starting from nothing, and so it does
              // not ask twice. But on a 360pt phone it pushed the second
              // question below the fold, which is the one thing this flow must
              // not do: the whole argument for one scroll over a wizard is that
              // she can SEE the ask is short. Reported exactly that way: "I
              // cannot even see the second question."
              //
              // Below the button it still does both jobs. The prefill on Q1 is
              // what actually stops the double-asking; this card only explains
              // where that prefill came from, and an explanation is worth more
              // once someone has met the thing being explained.
              const SizedBox(height: 30),
              _pad(_FactsCard(facts: _facts, p: p)),
              const SizedBox(height: 24),
        ]);
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
    return TtcToolScaffold(
      hue: kPcosHue,
      variant: 3,
      eyebrow: 'Your read',
      title: 'Here is what you told us,\nsaid back plainly.',
      children: [
              const SizedBox(height: 24),

              _pad(TtcToolBlockHead(
                  label: 'What your cycle looks like',
                  hue: 206,
                  mark: _standPainter(_StandMark.cycle, 206))),
              const SizedBox(height: 10),
              _pad(TtcToolBlock(text: result.cycleLine, hue: 206)),

              if (result.noticed.isNotEmpty) ...[
                const SizedBox(height: 26),
                _pad(TtcToolBlockHead(
                    label: 'What else you shared',
                    hue: 42,
                    mark: _standPainter(_StandMark.noticed, 42))),
                const SizedBox(height: 10),
                // ⚠️ ONE CARD PER LINE, NOT A BULLET LIST. Four observations
                // run together as bullets read as a case being assembled;
                // separated, each stays what it is — one thing worth
                // mentioning, with its own edges.
                for (final line in result.noticed) ...[
                  _pad(TtcToolBlock(text: line, hue: 42)),
                  const SizedBox(height: 8),
                ],
              ],

              const SizedBox(height: 26),
              _pad(TtcToolBlockHead(
                  label: 'What is worth doing next',
                  hue: 160,
                  mark: _standPainter(_StandMark.next, 160))),
              const SizedBox(height: 10),
              _pad(TtcToolBlock(text: result.always, hue: 160)),
              if (result.nudge != null) ...[
                const SizedBox(height: 8),
                // The nudge is the only card on the page that carries a border,
                // and that is the entire escalation this tool is allowed. No
                // red, no icon, no alarm word.
                _pad(TtcToolBlock(
                    text: result.nudge!, hue: 42, outlined: true)),
              ],

              const SizedBox(height: 20),
              _pad(TtcToolPrimary(
                label: 'Talk to a PCOS specialist',
                onTap: () => _openConsults(context),
              )),
              const SizedBox(height: 10),
              _pad(TtcToolSecondary(
                label: 'What to take with you',
                onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                        settings:
                            const RouteSettings(name: 'ttc/pcos_checklist'),
                        builder: (_) =>
                            TtcPcosChecklistScreen(result: result))),
              )),

              const SizedBox(height: 22),
              _pad(const TtcToolPrivacyLine()),
              const SizedBox(height: 26),
      ],
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

    return TtcToolScaffold(
      hue: kPcosHue,
      variant: 4,
      eyebrow: 'Appointment notes',
      title: 'What to take\nwith you.',
      intro: 'Screenshot this, or read it out. It is four lines.',
      children: [
              const SizedBox(height: 24),
              // ⚠️ THE SHARED CARD, NOT A LOCAL COPY OF IT — FOLDED IN
              // 2026-09-03. This screen predates `ttc_tool_chrome.dart` and
              // carried its own byte-identical version of the notes card: same
              // padding, same 9.5pt letter-spaced label, same divider, same
              // tinted disclaimer block at the foot.
              //
              // Two identical implementations of one appointment note is the
              // state that drifts, and it drifts in the worst place — the two
              // doors would slowly print a woman's own notes in two different
              // shapes, and she has no way to know which one her doctor is
              // used to reading. One card, both doors.
              _pad(TtcToolNotesCard(
                  rows: result.checklist,
                  disclaimer: kPcosChecklistDisclaimer)),
              const SizedBox(height: 18),
              _pad(TtcToolPrimary(
                label: 'Talk to a PCOS specialist',
                onTap: () => _openConsults(context),
              )),
              const SizedBox(height: 22),
              _pad(const TtcToolPrivacyLine()),
              const SizedBox(height: 26),
      ],
    );
  }
}

/// Which mark a result block carries.
enum _StandMark { cycle, noticed, next }

/// The drawn mark for a result block, in that block's own deep ink.
///
/// WARNING: A FUNCTION, BECAUSE `TtcToolBlockHead` TAKES A PAINTER RATHER THAN
/// AN ENUM. The private head this replaced knew about `_StandMark` and derived
/// the ink itself; the shared one is deliberately more general — it accepts any
/// `CustomPainter`, so a tool can draw whatever it needs — which means the
/// derivation moves here instead of being lost with the class.
_StandMarkPainter _standPainter(_StandMark mark, double hue) {
  final tint = v2BlockTint(hue % 360, V2PaletteStore.instance.current);
  return _StandMarkPainter(
    mark: mark,
    ink: HSLColor.fromColor(tint)
        .withSaturation(0.45)
        .withLightness(0.38)
        .toColor(),
  );
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

/// A single-choice option set. Generic so the four question shapes share one
/// control rather than four near-identical ones.
///
/// ⚠️ `onTap` TAKES A NULLABLE, AND THAT IS THE DESELECT. Reported as *"if I
/// click on an option, I should be able to deselect it — if I select it then it
/// just does not go back."* Which was true, and on this screen it was worse
/// than an inconvenience: every question here is optional, the result builds
/// from a half-filled form on purpose, and yet the first tap on any question
/// was irreversible. The screen offered "you can leave any of these blank" and
/// then would not let her go back to blank.
///
/// The toggle lives in [_Options] rather than at the eight call sites, so a
/// question added later cannot forget it.
class _Chips<T> extends StatelessWidget {
  const _Chips(
      {required this.value,
      required this.options,
      required this.onTap,
      required this.p});

  final T? value;
  final Map<T, String> options;

  /// Null means "she tapped the answer that was already chosen" — clear it.
  final ValueChanged<T?> onTap;
  final V2Palette p;

  @override
  Widget build(BuildContext context) => TtcToolOptions(
        p: p,
        items: [
          for (final e in options.entries)
            TtcToolOption(
                label: e.value,
                on: value == e.key,
                onTap: () => onTap(value == e.key ? null : e.key)),
        ],
      );
}

class _YesNo extends StatelessWidget {
  const _YesNo({required this.value, required this.onTap, required this.p});

  final PcosYesNo? value;
  final ValueChanged<PcosYesNo?> onTap;
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
  final ValueChanged<PcosDegree?> onTap;
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
  Widget build(BuildContext context) => TtcToolOptions(
        p: p,
        items: [
          TtcToolOption(
              label: "Haven't noticed",
              on: checked && selected.isEmpty,
              onTap: onNone,
              tick: true),
          for (final h in PcosHairArea.values)
            TtcToolOption(
                label: h.label,
                on: selected.contains(h),
                onTap: () => onToggle(h),
                tick: true),
        ],
      );
}


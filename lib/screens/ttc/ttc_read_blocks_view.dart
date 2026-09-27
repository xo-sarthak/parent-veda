// =============================================================================
//  TTC read blocks, drawn: the widgets behind `lib/ttc/ttc_read_blocks.dart`
// -----------------------------------------------------------------------------
//  Written 2026-09-26 from the TTC gap analysis. Two blocks so far:
//
//    · the age question at the top of "Trying for a baby after 35", and
//    · the drawing of a test line getting darker in "A faint line".
//
//  ⚠️ THE SHARED READER KNOWS NONE OF THIS. `PvReaderScreen` carries a
//  section's `custom` block as an opaque object and asks the stage to draw it
//  (`customBlock`). The two TTC openers, the surface router's `ttc_read/<id>`
//  and `openTtcArticle`, both pass [ttcReadCustomBlock]; that is the whole
//  wiring. A block this function does not know draws nothing, which is the
//  reader's own rule for a block with no renderer.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_fertility_help_rules.dart';
import '../../ttc/ttc_fertility_help_store.dart';
import '../../ttc/ttc_read_blocks.dart';
import '../../widgets/pv_feedback.dart';
import '../v2/v2_palette.dart';

/// The renderer both TTC reader openers hand to `PvReaderScreen.customBlock`.
Widget ttcReadCustomBlock(BuildContext context, Object block) =>
    switch (block) {
      TtcAgeBandAskBlock() => const TtcAgeBandAsk(),
      TtcFaintLineDrawingBlock() => const TtcFaintLineDrawing(),
      _ => const SizedBox.shrink(),
    };

// =============================================================================
//  Age, asked once
// =============================================================================
//
//  ⚠️ DERIVE, NEVER ASK, AND THIS IS THE ONE THING WE CANNOT DERIVE. Age is not
//  in any log. So it is asked, once, and the line under the question says what
//  the answer unlocks, because a bare "How old are you?" in a health app reads
//  as data collection.
//
//  ⚠️ THE SAME ANSWER THE TOOL KEEPS. The chips write
//  `TtcFertilityHelpStore.setAgeBand`, the `age` answer the fertility-help
//  tool and the IVF readiness flow already write. If she answered there, this
//  shows what she said instead of asking again; if she answers here, the tool
//  skips the question. That one value moves the see-a-doctor time to six
//  months (`TtcMessageFacts.monthsBeforeCheck`) and brings the IVF door's age
//  tab forward (`ttcDoorOrderedGroups`).

/// Test hooks.
Key ttcAgeBandChipKey(FertilityAgeBand b) => ValueKey('ttc-age-band-${b.name}');
const Key kTtcAgeBandChangeKey = ValueKey('ttc-age-band-change');
const Key kTtcAgeBandSavedKey = ValueKey('ttc-age-band-saved');

class TtcAgeBandAsk extends StatefulWidget {
  const TtcAgeBandAsk({super.key});

  @override
  State<TtcAgeBandAsk> createState() => _TtcAgeBandAskState();
}

class _TtcAgeBandAskState extends State<TtcAgeBandAsk> {
  /// True while she is changing a saved answer. Session only: reopening the
  /// read shows the saved line again, which is the resting state.
  bool _changing = false;

  @override
  void initState() {
    super.initState();
    // Idempotent. Local-first: a failed read is the same as no answer yet.
    TtcFertilityHelpStore.instance.load().catchError((_) {});
  }

  Future<void> _pick(FertilityAgeBand b) async {
    pvCommitFeedback();
    setState(() => _changing = false);
    await TtcFertilityHelpStore.instance.setAgeBand(b);
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge(
          [TtcFertilityHelpStore.instance, V2PaletteStore.instance]),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final saved = TtcFertilityHelpStore.instance.ageBand;
        final asking = saved == null || _changing;
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              top: BorderSide(color: p.line),
              bottom: BorderSide(color: p.line),
            ),
          ),
          child: asking ? _ask(p, saved) : _saved(p, saved),
        );
      },
    );
  }

  Widget _ask(V2Palette p, FertilityAgeBand? saved) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('How old are you?',
              style: pvFraunces(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                  height: 1.3,
                  color: p.ink1)),
          const SizedBox(height: 6),
          Text(
              'So we can tell you the right time to ask for a check. '
              'Nothing else uses it.',
              style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final b in FertilityAgeBand.values)
                _chip(p, b, on: b == saved),
            ],
          ),
        ],
      );

  Widget _chip(V2Palette p, FertilityAgeBand b, {required bool on}) =>
      PvPress(
        child: Semantics(
          button: true,
          selected: on,
          child: InkWell(
            key: ttcAgeBandChipKey(b),
            onTap: () => _pick(b),
            borderRadius: BorderRadius.circular(999),
            child: Container(
              height: 40,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: on ? p.ink1 : p.surface,
                borderRadius: BorderRadius.circular(999),
                border: Border.all(color: on ? p.ink1 : p.line, width: 1.2),
              ),
              child: Text(b.label.en,
                  style: pvManrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: on ? p.surface : p.ink1)),
            ),
          ),
        ),
      );

  Widget _saved(V2Palette p, FertilityAgeBand band) => Row(
        key: kTtcAgeBandSavedKey,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Text(
                // `.en` for display is right here: the label is English only
                // and this line is never saved or compared.
                "You told us you're ${band.label.en.toLowerCase()}. We use "
                'it only to time when we suggest a check.',
                style: pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
          ),
          const SizedBox(width: 12),
          InkWell(
            key: kTtcAgeBandChangeKey,
            onTap: () => setState(() => _changing = true),
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
              child: Text('Change',
                  style: pvManrope(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: p.ink1,
                      decoration: TextDecoration.underline)),
            ),
          ),
        ],
      );
}

// =============================================================================
//  A faint line, getting clearer
// =============================================================================
//
//  ⚠️ DRAWN, NOT PHOTOGRAPHED, AND NO BRAND. A photo of a real test is a
//  brand, a lighting condition and a camera, which is exactly what the read's
//  own tip warns makes lines look darker or lighter than they are. Four line
//  drawings of one plain cassette show only the thing that matters: the
//  control line stays the same, and the test line fills in.
//
//  ⚠️ NO HORMONE NUMBERS AND NO "YOU". The labels are days from the day the
//  period is due, and the caption says "usually". A drawing that promised her
//  line will darken would be a prediction about her pregnancy.

/// How strong the test line is in each window, from very faint to clear.
/// The control line is always 1.
const List<({String label, double strength})> kTtcFaintLineDays = [
  (label: 'Day due', strength: 0.16),
  (label: '+2 days', strength: 0.36),
  (label: '+4 days', strength: 0.62),
  (label: '+6 days', strength: 0.92),
];

const String kTtcFaintLineCaption = 'A faint line that shows up within the '
    'reading time usually gets clearer over a few days.';

class TtcFaintLineDrawing extends StatelessWidget {
  const TtcFaintLineDrawing({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: V2PaletteStore.instance,
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        // A muted rose, the colour a test line is, kept soft so it reads as
        // a drawing and never as an alarm.
        final dye = const HSLColor.fromAHSL(1, 344, 0.42, 0.52).toColor();
        return Semantics(
          label: 'A drawing of four tests taken two days apart. The control '
              'line is the same each time, and the test line goes from very '
              'faint to clear.',
          child: ExcludeSemantics(
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 18),
              decoration: BoxDecoration(
                border: Border(
                  top: BorderSide(color: p.line),
                  bottom: BorderSide(color: p.line),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      for (final d in kTtcFaintLineDays)
                        Expanded(
                          child: Column(children: [
                            SizedBox(
                              width: 52,
                              height: 116,
                              child: CustomPaint(
                                painter: TtcTestWindowPainter(
                                  strength: d.strength,
                                  outline: p.ink2,
                                  mark: p.ink3,
                                  dye: dye,
                                  fill: p.surface,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(d.label,
                                textAlign: TextAlign.center,
                                style: pvManrope(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: p.ink2)),
                          ]),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(kTtcFaintLineCaption,
                      style: pvManrope(
                          fontSize: 14, height: 1.5, color: p.ink2)),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

/// One plain test cassette in line art: a rounded body, a reading window
/// with the control line (C) and the test line (T), and the sample well.
class TtcTestWindowPainter extends CustomPainter {
  TtcTestWindowPainter({
    required this.strength,
    required this.outline,
    required this.mark,
    required this.dye,
    required this.fill,
  });

  /// 0 to 1: how strong the test line is. The control line is always full.
  final double strength;
  final Color outline, mark, dye, fill;

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final stroke = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = outline
      ..isAntiAlias = true;

    // The body.
    final body = RRect.fromRectAndRadius(
        Rect.fromLTWH(1, 1, w - 2, h - 2), Radius.circular(w * 0.28));
    canvas.drawRRect(body, Paint()..color = fill);
    canvas.drawRRect(body, stroke);

    // The reading window.
    final win = RRect.fromRectAndRadius(
        Rect.fromLTWH(w * 0.26, h * 0.16, w * 0.48, h * 0.42),
        const Radius.circular(5));
    canvas.drawRRect(win, stroke..strokeWidth = 1.2);

    // The two lines, across the window.
    final lineH = h * 0.04;
    final left = win.left + w * 0.06, right = win.right - w * 0.06;
    final cY = win.top + win.height * 0.32;
    final tY = win.top + win.height * 0.68;
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(left, cY - lineH / 2, right, cY + lineH / 2),
            const Radius.circular(1.5)),
        Paint()..color = dye);
    canvas.drawRRect(
        RRect.fromRectAndRadius(
            Rect.fromLTRB(left, tY - lineH / 2, right, tY + lineH / 2),
            const Radius.circular(1.5)),
        Paint()..color = dye.withValues(alpha: strength.clamp(0.0, 1.0)));

    // "C" and "T" beside the window, as a real cassette prints them.
    for (final (letter, y) in [('C', cY), ('T', tY)]) {
      final tp = TextPainter(
        text: TextSpan(
            text: letter,
            style: TextStyle(
                fontSize: 8.5, fontWeight: FontWeight.w700, color: mark)),
        textDirection: TextDirection.ltr,
      )..layout();
      tp.paint(canvas,
          Offset(win.right + w * 0.06, y - tp.height / 2));
    }

    // The sample well.
    canvas.drawCircle(Offset(w / 2, h * 0.78), w * 0.13,
        stroke..strokeWidth = 1.2);
  }

  @override
  bool shouldRepaint(TtcTestWindowPainter old) =>
      old.strength != strength ||
      old.outline != outline ||
      old.mark != mark ||
      old.dye != dye ||
      old.fill != fill;
}

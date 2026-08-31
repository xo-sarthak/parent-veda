// =============================================================================
//  Tool chrome — the V3 shell every TTC tool wears
// -----------------------------------------------------------------------------
//  ⚠️ EXTRACTED BECAUSE FIVE DOORS ARE BEING REBUILT AND EVERY ONE OF THEM
//  WIRES TOOLS. The standing instruction is that a tool wired into a door gets
//  brought up to the V3 language, not merely made reachable — and five sessions
//  each re-implementing a hero field, a sheet, a chip and a progress line is
//  how five tools end up looking like four different apps.
//
//  ⚠️ `ttc_pcos_stand_screen.dart` PREDATES THIS FILE AND STILL CARRIES ITS OWN
//  COPIES. It is where the shape was designed, so the two are identical today —
//  and that is exactly the state that drifts. Folding it onto these widgets is a
//  mechanical change worth doing on purpose rather than as a footnote to
//  something else, because it touches a working screen and the payoff is
//  hygiene rather than behaviour. Until then: **change both, or change neither.**
//
//  This is the shape that was approved on "Where do I stand" in the PCOS door.
//  It is a set of parts rather than a template on purpose: a tool that needs a
//  ruler, a chart or a body-area picker still builds that itself and drops it
//  into `TtcToolQuestion` like any other control.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE PARTS THAT ARE ABOUT COMPREHENSION, NOT DECORATION
//  ---------------------------------------------------------------------------
//
//  Two of these exist for reasons that are easy to strip out later as clutter,
//  so they are argued here rather than at the call site:
//
//  · **`TtcToolProgress` is a filling line and never "3 of 8".** A counter on a
//    health questionnaire is a debt statement — it tells her how much is still
//    owed. A line answers the same question without putting a number on the
//    remainder, and it moves visibly on every tap, which is the part that
//    reassures rather than the part that informs.
//
//  · **`TtcToolQuestion` numbers itself.** On a long scroll the progress line
//    is off screen most of the time; the number is what tells her, at any point,
//    roughly where she is. It is the same job said a second way, and both are
//    needed because they are visible at different moments.
//
//  ---------------------------------------------------------------------------
//  ⚠️ HAIRLINES, NOT SHADOWS, ON EVERYTHING INSIDE THE SHEET
//  ---------------------------------------------------------------------------
//
//  The sheet itself casts one upward shadow, because it is a surface sliding
//  over the field. Nothing inside it does. Eight stacked shadows on one scroll
//  is a page that looks like it is hovering, and it is the single fastest way to
//  make a calm screen feel busy.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_hero_field.dart';
import 'ttc_common.dart';

/// The gutter every tool screen uses. One constant so two tools cannot disagree
/// by two points.
Widget ttcToolPad(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: child);

/// Field, hero and sheet, in one call.
///
/// ⚠️ THE HERO SAYS WHAT THE TOOL IS *AND WHAT IT IS NOT*, above the first
/// input. On a screen that could be mistaken for a diagnostic quiz, "this is
/// not a diagnosis" arriving at the end arrives after she has already decided
/// what the screen was. `intro` is the place for that sentence and it is
/// required rather than optional for exactly that reason.
class TtcToolScaffold extends StatelessWidget {
  const TtcToolScaffold({
    super.key,
    required this.hue,
    required this.eyebrow,
    required this.title,
    required this.intro,
    required this.children,
    this.variant = 2,
    this.action,
  });

  final double hue;

  /// Small, letterspaced, above the title. The tool's name.
  final String eyebrow;

  /// One Fraunces line. What this screen is.
  final String title;

  /// One Manrope sentence. What it will and will not do.
  final String intro;

  /// Everything inside the sheet.
  final List<Widget> children;

  /// Which composition the field draws. Vary it between a tool's screens so a
  /// flow does not look like one page repeated.
  final int variant;

  /// An optional control in the hero, opposite the close button.
  ///
  /// ⚠️ FOR "ADD", AND FOR ALMOST NOTHING ELSE. Several TTC tools are lists you
  /// add to — records, medicines, appointments — and their old back bar carried
  /// the add button as a trailing widget. Dropping that into the sheet as the
  /// first row would put a control above the content it acts on, which reads as
  /// a header nobody asked for.
  ///
  /// So it lives where it lived: top right, opposite the way out. One slot, not
  /// a list, because a hero with two actions in it is a toolbar.
  final Widget? action;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    // ⚠️ `% 360` IS ARITHMETIC, NOT PADDING. `v2BlockTint` asserts hue <= 360
    // and a hue arriving from a data file has already tripped it once in this
    // stage. A hue is an angle.
    final accent = v2BlockTint(hue % 360, p);

    return Scaffold(
      backgroundColor: p.ground,
      body: Stack(children: [
        Positioned.fill(
          child: V3HeroField(
              accent: accent, ground: p.ground, variant: variant),
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
                      Row(children: [
                        const TtcToolClose(),
                        if (action != null) ...[
                          const Spacer(),
                          action!,
                        ],
                      ]),
                      const SizedBox(height: 14),
                      Text(eyebrow.toUpperCase(),
                          style: pvManrope(
                              fontSize: 10,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 1.3,
                              color: p.ink2)),
                      const SizedBox(height: 8),
                      Text(title,
                          style: pvFraunces(
                              fontSize: 26,
                              fontWeight: FontWeight.w600,
                              height: 1.2,
                              letterSpacing: -0.5,
                              color: p.ink1)),
                      const SizedBox(height: 10),
                      Text(intro,
                          style: pvManrope(
                              fontSize: 13.5, height: 1.6, color: p.ink2)),
                    ]),
              ),
            ),
            _Sheet(p: p, children: children),
          ],
        ),
      ]),
    );
  }
}

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

/// A round translucent close button, not an `AppBar`.
///
/// ⚠️ NO APP BAR ON A TOOL, DELIBERATELY. An app bar is a horizontal band of
/// solid colour across the top, which cuts the hero field off at exactly the
/// point the composition is doing its work. A floating button leaves the field
/// whole and still gives the one control a tool needs.
class TtcToolClose extends StatelessWidget {
  const TtcToolClose({super.key});

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Semantics(
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
              color: p.surface.withValues(alpha: 0.9), shape: BoxShape.circle),
          child: Icon(Icons.close_rounded, size: 19, color: p.ink1),
        ),
      ),
    );
  }
}

/// How far through. See the header for why this is a line and not a count.
class TtcToolProgress extends StatelessWidget {
  const TtcToolProgress({
    super.key,
    required this.done,
    required this.total,
    this.startLabel = 'A FEW SHORT QUESTIONS',
    this.goingLabel = 'KEEP GOING',
  });

  final int done;
  final int total;
  final String startLabel;
  final String goingLabel;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(done == 0 ? startLabel : goingLabel,
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
          FractionallySizedBox(
            widthFactor: total == 0 ? 0 : (done / total).clamp(0.0, 1.0),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 260),
              curve: Curves.easeOut,
              height: 4,
              color: ttcPurple,
            ),
          ),
        ]),
      ),
    ]);
  }
}

/// One question, as a card with a numbered chip.
class TtcToolQuestion extends StatelessWidget {
  const TtcToolQuestion({
    super.key,
    required this.n,
    required this.title,
    required this.hue,
    required this.child,
    this.note,
  });

  final int n;
  final String title;
  final double hue;
  final String? note;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(hue % 360, p);
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.fromLTRB(16, 15, 16, 16),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
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
                style: pvManrope(fontSize: 12, height: 1.45, color: p.ink3)),
          ),
        ],
        const SizedBox(height: 14),
        child,
      ]),
    );
  }
}

/// One selectable pill.
class TtcToolPill extends StatelessWidget {
  const TtcToolPill({
    super.key,
    required this.label,
    required this.on,
    required this.onTap,
    required this.hue,
  });

  final String label;
  final bool on;
  final VoidCallback onTap;
  final double hue;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: on ? v2BlockTint(hue % 360, p) : ttcPanel,
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
}

/// A single-choice pill set. Generic so every question shape shares one control
/// rather than each door growing its own.
class TtcToolChoice<T> extends StatelessWidget {
  const TtcToolChoice({
    super.key,
    required this.value,
    required this.options,
    required this.onTap,
    required this.hue,
  });

  final T? value;
  final Map<T, String> options;
  final ValueChanged<T> onTap;
  final double hue;

  @override
  Widget build(BuildContext context) => Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          for (final e in options.entries)
            TtcToolPill(
                label: e.value,
                on: value == e.key,
                onTap: () => onTap(e.key),
                hue: hue),
        ],
      );
}

/// A tinted block of prose in a result.
class TtcToolBlock extends StatelessWidget {
  const TtcToolBlock({
    super.key,
    required this.text,
    required this.hue,
    this.outlined = false,
  });

  final String text;
  final double hue;

  /// ⚠️ THE ENTIRE ESCALATION VOCABULARY OF A TTC TOOL IS ONE HAIRLINE. No red,
  /// no warning icon, no alarm word. If a result needs to be more insistent than
  /// its neighbours, it gets a border and nothing else.
  final bool outlined;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(hue % 360, p);
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

/// A result block's heading, with an optional drawn mark beside it.
class TtcToolBlockHead extends StatelessWidget {
  const TtcToolBlockHead({
    super.key,
    required this.label,
    required this.hue,
    this.mark,
  });

  final String label;
  final double hue;

  /// A `CustomPaint`, drawn by the tool. Not an `Icon` — see the note on
  /// `ttc_symptom_mark.dart` for why this stage draws its own marks.
  final CustomPainter? mark;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final tint = v2BlockTint(hue % 360, p);
    return Row(children: [
      Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
        child: mark == null ? null : CustomPaint(painter: mark),
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

/// The filled action. One per screen.
class TtcToolPrimary extends StatelessWidget {
  const TtcToolPrimary({super.key, required this.label, required this.onTap});

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

class TtcToolSecondary extends StatelessWidget {
  const TtcToolSecondary({super.key, required this.label, required this.onTap});

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

/// "This stays on your phone. It is not a medical record."
///
/// ⚠️ A COMPONENT BECAUSE IT MUST NOT DRIFT. Every self-assessment in this stage
/// owes the reader this sentence, and a sentence typed at six call sites is a
/// sentence that ends up saying six things.
class TtcToolPrivacyLine extends StatelessWidget {
  const TtcToolPrivacyLine({super.key});

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Icon(Icons.lock_outline_rounded, size: 15, color: p.ink3),
      const SizedBox(width: 9),
      Expanded(
        child: Text('This stays on your phone. It is not a medical record.',
            style: pvManrope(fontSize: 11.5, height: 1.5, color: p.ink3)),
      ),
    ]);
  }
}

/// The appointment-prep card, drawn as a piece of paper rather than an app card.
///
/// ⚠️ FIRST PERSON LABELS, ALWAYS. "My cycle pattern", not "Her cycle pattern"
/// and not "Findings". The moment this reads as the app's assessment, a doctor
/// is being handed a second opinion from a phone; as her own notes it is exactly
/// what a good appointment starts with.
class TtcToolNotesCard extends StatelessWidget {
  const TtcToolNotesCard({
    super.key,
    required this.rows,
    required this.disclaimer,
  });

  final List<({String label, String value})> rows;
  final String disclaimer;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 18),
      decoration: BoxDecoration(
        color: p.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: p.line),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        for (var i = 0; i < rows.length; i++) ...[
          if (i > 0) ...[
            const SizedBox(height: 15),
            Divider(color: p.line, height: 1),
            const SizedBox(height: 15),
          ],
          Text(rows[i].label.toUpperCase(),
              style: pvManrope(
                  fontSize: 9.5,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.9,
                  color: p.ink3)),
          const SizedBox(height: 6),
          Text(rows[i].value,
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
          child: Text(disclaimer,
              style: pvManrope(
                  fontSize: 12.5,
                  height: 1.55,
                  fontWeight: FontWeight.w700,
                  color: p.ink2)),
        ),
      ]),
    );
  }
}

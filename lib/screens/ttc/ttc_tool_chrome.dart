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
import 'package:flutter/services.dart';

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
    required this.children,
    this.intro,
    this.variant = 2,
    this.action,
    this.heroLead,
    this.scrollController,
    this.chroma,
  });

  final double hue;

  /// How saturated the tinted field behind the sheet is.
  ///
  /// ⚠️ NULL MEANS THE STAGE DEFAULT, AND ALMOST EVERYTHING SHOULD LEAVE IT
  /// NULL. `v3FieldChroma` solves for one CIELAB C* across every hue so that a
  /// rose door and a teal door feel equally strong — which is the right rule
  /// for content areas that sit beside each other in a list.
  ///
  /// The shop is the exception it was written for. Its field came out flat
  /// beside the design's own bright pink, and a product surface is the one
  /// place in this stage that is allowed to look inviting rather than calm.
  /// Reported as "stop using such dull colors".
  final double? chroma;

  /// ⚠️ OPTIONAL, AND ONLY THE PRODUCT PAGE PASSES ONE. The design's sticky
  /// buy bar "appears on scroll", which means something outside has to know
  /// the offset. Everything else leaves this null and gets the ListView's own
  /// controller exactly as before.
  final ScrollController? scrollController;

  /// Small, letterspaced, above the title. The tool's name.
  final String eyebrow;

  /// One Fraunces line. What this screen is.
  final String title;

  /// One Manrope sentence. What it will and will not do.
  ///
  /// WARNING: NULLABLE, AND THE EXCEPTION IS NARROW. It used to be required, on
  /// the argument at the head of this class: on a screen that could be mistaken
  /// for a diagnostic quiz, "this is not a diagnosis" arriving at the end
  /// arrives after she has already decided what the screen was.
  ///
  /// That argument is about a screen that ASKS. A RESULT has already been
  /// framed -- she read the intro on the way in and answered eight questions
  /// under it -- and inventing a second sentence to satisfy a required
  /// parameter would put copy on the page to please a constructor.
  ///
  /// So: leave it out only where nothing is being asked. On a tool's first
  /// screen a missing intro is a missing sentence, not a null.
  final String? intro;

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

  /// Sits in the hero between the close row and the eyebrow.
  ///
  /// ⚠️ FOR A CHOICE THAT SCOPES EVERYTHING BELOW IT, and for nothing else. The
  /// cycle report opens on one cycle out of several and its ◀ ▶ picker decides
  /// what every card underneath is about — a control like that cannot sit in
  /// the sheet, because then the page has already begun answering before she
  /// has said which question she is asking.
  ///
  /// It is deliberately not a general "put anything here" slot. A hero with a
  /// stack of controls in it is a toolbar, which is the thing `TtcToolClose`
  /// exists to avoid. One widget, and it should be a scope, not an action.
  final Widget? heroLead;

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
              accent: accent,
              ground: p.ground,
              variant: variant,
              chroma: chroma ?? v3FieldChroma(hue % 360)),
        ),
        ListView(
          controller: scrollController,
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
                      if (heroLead != null) ...[
                        const SizedBox(height: 14),
                        heroLead!,
                      ],
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
                      if (intro case final line?) ...[
                        const SizedBox(height: 10),
                        Text(line,
                            style: pvManrope(
                                fontSize: 13.5, height: 1.6, color: p.ink2)),
                      ],
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
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 130),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        // Same treatment as `_ToolOptionBlock`: white with a hairline at
        // rest, ink when chosen. See the header there.
        decoration: BoxDecoration(
          color: on ? ttcTitleInk : Colors.white,
          borderRadius: BorderRadius.circular(999),
          border: Border.all(color: on ? ttcTitleInk : ttcLine, width: 1.5),
        ),
        child: Text(label,
            style: pvManrope(
                fontSize: 13,
                fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                color: on ? Colors.white : ttcTitleInk)),
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

  /// ⚠️ NULLABLE NOW. Tapping the chosen answer clears it, so a question is
  /// never a trap — the same rule the PCOS self-read is held to, and it has to
  /// be here rather than at each call site or a question added later forgets.
  final ValueChanged<T?> onTap;
  final double hue;

  @override
  Widget build(BuildContext context) => TtcToolOptions(
        p: V2PaletteStore.instance.current,
        hue: hue,
        items: [
          for (final e in options.entries)
            TtcToolOption(
                label: e.value,
                on: value == e.key,
                onTap: () => onTap(value == e.key ? null : e.key)),
        ],
      );
}


// =============================================================================
//  Choosing an answer
// -----------------------------------------------------------------------------
//  ⚠️ PROMOTED OUT OF `ttc_pcos_stand_screen.dart`, WHERE IT WAS AHEAD OF THIS
//  FILE RATHER THAN BEHIND IT. The shared control used to be `TtcToolPill` in a
//  `Wrap`, and two separate complaints landed on it from two different screens:
//
//    · **The wasted space.** A wrap of label-sized pills ends every row
//      wherever the last one happens to fit, leaving a ragged strip down the
//      right of every question — *"a lot of spaces again, being wasted."*
//    · **The purple.** A chosen pill took a `ttcPurple` border. The accent is
//      spent at decision points and never used to outline eight questions'
//      worth of blocks — *"I can see a purple bar which isn't what we are
//      following right now to select an option."*
//
//  So the row is DIVIDED rather than filled: every block in a row is the same
//  width, the row reaches both edges, and a short last row stretches instead of
//  leaving a gap. Selection is the block's own tint with an ink edge, never the
//  accent.
//
//  ⚠️ AND THE CHECKBOX IS SINGLE-PURPOSE. A tick is a promise that more than
//  one answer may be given. See [TtcToolOption.tick].
// =============================================================================

/// One option, before it is laid out. A record would do; a tiny class keeps the
/// three fields named at every call site.
class TtcToolOption {
  const TtcToolOption(
      {required this.label,
      required this.on,
      required this.onTap,
      this.tick = false});

  final String label;
  final bool on;
  final VoidCallback onTap;

  /// Whether this block draws a checkbox.
  ///
  /// WARNING: ONLY ON A QUESTION THAT CAN HOLD SEVERAL ANSWERS, which here is
  /// the hair-area picker and nothing else. The first cut ticked every block on
  /// the page, reasoning that with deselect available every question is "none
  /// or one" and so behaves like a set of checkboxes. That is true of the
  /// MECHANICS and wrong about the READING: a checkbox is a promise that you
  /// may choose more than one, and seven questions made that promise and then
  /// broke it on the second tap.
  ///
  /// Said plainly: "check boxes are only necessary when there are more than one
  /// choices." The fill and the border already say a single-choice block is
  /// chosen, which is what it looked like before the ticks arrived.
  final bool tick;
}


/// The answers to one question, as blocks that fill the row.
///
/// ⚠️ THIS REPLACED A `Wrap` OF PILLS, AND THE WRAP IS WHY THE PAGE FELT EMPTY.
/// Reported as *"eight short questions… a lot of spaces again, being wasted"*,
/// and a `Wrap` of label-sized pills is the mechanism: every row ended wherever
/// the last pill happened to fit and left a ragged strip of nothing down the
/// right-hand side of all eight questions. Nobody wrote that space; it was the
/// residue of laying out by content width.
///
/// So the row is divided instead of filled. Every option in a row is the same
/// width, the row always reaches both edges, and — the part that actually
/// recovers the space — **a short last row stretches rather than leaving a
/// gap**: four options in three columns puts one full-width block underneath,
/// not one small one with two-thirds of a row beside it.
///
/// ⚠️ THE COLUMN COUNT COMES FROM THE LONGEST LABEL, NOT FROM THE COUNT. Three
/// across for "Yes / No / Not sure", two across for "Often longer than 35". A
/// fixed three would wrap the long ones onto two lines and a fixed two would
/// waste half a row on the short ones — the choice has to follow the words.
class TtcToolOptions extends StatelessWidget {
  const TtcToolOptions({
    super.key,
    required this.items,
    required this.p,
    this.hue = 288,
  });

  final List<TtcToolOption> items;
  final V2Palette p;

  /// The tint a chosen block takes.
  ///
  /// ⚠️ DEFAULTED, NOT REQUIRED, BECAUSE THIS CONTROL WAS DESIGNED ON ONE
  /// SCREEN. 288 is the PCOS violet it grew up in; every other tool passes its
  /// own hue, and the default is there so a call site that forgets gets a
  /// deliberate colour rather than a compile error nobody reads.
  final double hue;

  static const double _gap = 8;

  @override
  Widget build(BuildContext context) {
    final longest =
        items.fold<int>(0, (n, o) => o.label.length > n ? o.label.length : n);
    // ⚠️ NINE, NOT TWELVE, AND THE THREE CHARACTERS WERE MEASURED. A block is
    // not all label: 22pt of padding, an 18pt mark and a 9pt gap come off the
    // column before a word is drawn, so a third of 354pt leaves about 64pt of
    // text. "Not sure" wrapped at twelve. The count has to be chosen against
    // the space the label actually gets, not against the column.
    final cols = longest <= 9 ? 3 : 2;

    final rows = <Widget>[];
    for (var i = 0; i < items.length; i += cols) {
      final end = (i + cols) < items.length ? (i + cols) : items.length;
      final slice = items.sublist(i, end);
      rows.add(
        // ⚠️ `IntrinsicHeight` BUYS ONE THING AND IT IS WORTH THE PASS: every
        // block in a row is as tall as the tallest. Without it a label that
        // wraps to two lines leaves its neighbours short and the row reads as
        // broken — which is what the first cut of this did to "Yes / No / Not
        // sure". It is an extra layout pass over three small boxes, not over a
        // list, so the usual objection to it does not apply here.
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              for (var j = 0; j < slice.length; j++) ...[
                if (j > 0) const SizedBox(width: _gap),
                // ⚠️ `Expanded`, WHICH IS WHAT FILLS THE LAST ROW. Four options
                // in three columns leaves one on its own, and it now spans the
                // full width instead of sitting in a third of it with the other
                // two-thirds empty. That gap, repeated down eight questions,
                // was the wasted space this control was rebuilt to recover.
                Expanded(child: _ToolOptionBlock(opt: slice[j], p: p, hue: hue)),
              ],
            ],
          ),
        ),
      );
    }

    return Column(children: [
      for (var i = 0; i < rows.length; i++) ...[
        if (i > 0) const SizedBox(height: _gap),
        rows[i],
      ],
    ]);
  }
}


/// One answer. A block, not a pill.
///
/// ⚠️ THE MARK IS WHAT FILLS IT. A pill grown into a rectangle is a bigger
/// empty pill — the same trap the group tabs on the focus page fell into twice.
/// The 18pt rounded square on the left gives the block a left edge with
/// something in it, and it does a second job the pill could not: it says
/// out loud that an answer can be turned OFF again. A tinted pill with no
/// control on it looks like a state the screen chose; a box with a tick in it
/// looks like a thing you can untick, which is now true.
///
/// ⚠️ A SQUARE ON SINGLE-CHOICE QUESTIONS TOO, WHICH USUALLY MEANS "MANY". It
/// is the honest shape here: with deselect, every question on this page really
/// is "none or one" rather than "exactly one", and a radio that cannot be
/// cleared is the control this screen just stopped being.
///
/// ---------------------------------------------------------------------------
/// ⚠️ ONE SELECTION TREATMENT FOR EVERY TOOL — 2026-09-06
/// ---------------------------------------------------------------------------
///
/// Until now a resting block was `ttcPanel` — a grey with a violet cast — and a
/// chosen block took the DOOR'S HUE as a fill. On His side that hue is teal,
/// so the report came back as: *"initially it's like purple, I click on it, it
/// gets a blue background"*. Both halves were true. The resting grey read as
/// purple beside white cards, and "the chosen answer takes the door's colour"
/// meant three tools with three different chosen colours and none of them
/// looking chosen so much as coloured in.
///
/// So the block now follows the rule the buttons already follow — *white with
/// a hairline* at rest — and a chosen block is INK: dark fill, white text. Not
/// the accent, not a hue, the same ink the titles are set in. It is
/// unmistakably "this one", it is identical on PCOS, IVF and His side, and
/// nothing on the page is coloured by which door you came in through.
///
/// And it answers the finger: the block scales down while pressed and clicks
/// once on release. A control that changes colour 130ms after the tap, with
/// nothing between, was the "not very responsive" in the same report.
class _ToolOptionBlock extends StatefulWidget {
  const _ToolOptionBlock(
      {required this.opt, required this.p, required this.hue});

  final TtcToolOption opt;
  final V2Palette p;

  /// Kept on the signature so no call site changes; no longer drawn. See the
  /// header — a chosen answer is ink on every tool, not the door's colour.
  final double hue;

  @override
  State<_ToolOptionBlock> createState() => _ToolOptionBlockState();
}

class _ToolOptionBlockState extends State<_ToolOptionBlock> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final opt = widget.opt;
    final on = opt.on;
    return Semantics(
      selected: on,
      button: true,
      label: opt.label,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: () {
          HapticFeedback.selectionClick();
          opt.onTap();
        },
        behavior: HitTestBehavior.opaque,
        child: AnimatedScale(
          scale: _pressed ? 0.965 : 1,
          duration: const Duration(milliseconds: 90),
          curve: Curves.easeOut,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            curve: Curves.easeOutCubic,
            padding: const EdgeInsets.fromLTRB(11, 12, 11, 12),
            decoration: BoxDecoration(
              color: on ? ttcTitleInk : Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                  color: on ? ttcTitleInk : ttcLine, width: 1.5),
            ),
            child: Row(children: [
              if (opt.tick) ...[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  width: 18,
                  height: 18,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: on ? Colors.white : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: on ? null : Border.all(color: ttcLine, width: 1.5),
                  ),
                  child: on
                      ? const Icon(Icons.check_rounded,
                          size: 13, color: ttcTitleInk)
                      : null,
                ),
                const SizedBox(width: 9),
              ],
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 160),
                  textAlign: opt.tick ? TextAlign.start : TextAlign.center,
                  style: pvManrope(
                      fontSize: 12.5,
                      height: 1.25,
                      fontWeight: on ? FontWeight.w800 : FontWeight.w600,
                      color: on ? Colors.white : ttcTitleInk),
                  child: Text(opt.label),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
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
            // ⚠️ WHITE WITH A HAIRLINE. NOT THE ACCENT, AND NOT FILLED.
            //
            // This was `ttcPurple` and it was the stage's odd one out. The rule
            // is already written down on `_QuietButton` at the foot of the
            // symptom logger — *"ONE BUTTON TREATMENT ON THIS STAGE: white with
            // a hairline"* — and restated as a direct instruction: the buttons
            // are not purple.
            //
            // The reasoning behind that rule is the design system's own: the
            // accent is spent at decision points and never laid down as a
            // SURFACE. A full-width filled bar is a surface whatever it does
            // when tapped, and on a page of pale tinted blocks it is also the
            // loudest object present — which puts the emphasis on the control
            // rather than on what the reader came to read.
            //
            // ⚠️ THIS CHANGED `ttc_ivf_readiness_screen.dart` TOO, which was
            // the only other caller. That is the point of folding rather than
            // forking: the PCOS tool had already been corrected to white by
            // hand, and leaving the shared one purple would have meant two TTC
            // tools with two different primary buttons and a rule that only
            // one of them followed.
            color: Colors.white,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: ttcLine),
          ),
          child: Text(label,
              style: pvManrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: ttcTitleInk)),
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

// =============================================================================
//  V3PregHero — the pregnancy home's fold, in the TTC home's structure
// -----------------------------------------------------------------------------
//  2026-09-22, the user, holding the two homes side by side: "Trying to
//  Conceive looks 1000 times better … top left, top right we're having the
//  profile and the calendar; the date at the top; then the horizontal scroll
//  bar. Right now the pregnancy looks like randomly placed stuff." And on the
//  first pass at this file — a photograph in a ringed circle on a green
//  field — "a profile photo put in between … two different things put
//  together, not one whole thing." Then: "do it exactly like Flo."
//
//  So this is Flo's home (Mobbin §15/§17), in TTC's structure:
//
//     [avatar]        22 September        [saved]
//     S   S   M  (TODAY)  W   T   F         ← the strip, ink digits, ink disc
//
//                   Week 4 · Day 7          ← inside the glow, at the top
//                 ·  the baby, 2D  ·        ← the figure with its own pink
//                ·   dissolving into  ·        halo, no edge, no ring — the
//                 ·    the field    ·         field is the same warm peach
//                     ( Details )            ← the pill, inside, at the foot
//     ╭────────────────────────────────────╮
//     │ MY DAILY INSIGHTS · Today …        │  ← the white sheet slides over
//
//  ⚠️ ONE THING, NOT TWO. The field is the art's own hue (peach, 20°) in
//  every trimester, and the figure is `assets/baby2d/week_NN.png` — the 2D
//  set from lib/data/baby-images, its square edge faded to nothing, so the
//  pink halo the illustrator painted becomes the disc and the disc becomes
//  the field. Nothing is clipped, nothing is ringed.
//
//  ⚠️ THE HERO SAYS THE WEEK AND OPENS THE WEEK — NOTHING ELSE. No size line,
//  no "This week" pill under it: "we are legit saying in today's insights
//  about the size of a poppy seed, and you have also written that same thing
//  above as well … a wastage of space." The size lives on the insight card
//  and on the week page. `Details` is Flo's word and opens `PregWeekScreen`.
//
//  `V3Hero` (v3_sections.dart), the full-bleed photograph, stays for revert.
// =============================================================================

import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../services/stage_gateway.dart' show showStageDoorMenu;
import '../../theme/pv_fonts.dart';
import 'pv_day_strip.dart';
import 'v2_palette.dart';

/// The field's hue behind the pregnancy fold — KEPT FOR REVERT. It fed
/// `V3HeroField`, whose equalised-chroma recipe turns a warm hue into khaki
/// ("why is green there?" — the user, 2026-09-22, and he was right: the
/// deep stops of a low-chroma 20° read as olive). The field is `PregField`
/// now, made of the art's own sampled colours.
const double kPregFieldHue = 20;

/// The art's own colours, sampled from the masters: the halo the
/// illustrator painted around every figure (255, 228, 217) and the paler
/// edge of the frame (254, 242, 238). The field is these and nothing else,
/// so the figure, its glow and the page are one surface.
const Color kPregHalo = Color(0xFFFFE4D9);
const Color kPregHaloEdge = Color(0xFFFEF2EE);

/// The pregnancy fold's field: `V3HeroField`'s composition — the diagonal
/// wash, the two great circles, the dot grain — painted in the ART'S colours
/// instead of a hue pushed through the shared recipe. The user liked the
/// composition and not the khaki it made of a warm hue (2026-09-22); the
/// shared field's "mid" stop and second circle shift the hue by +34°, which
/// from peach lands on yellow, and yellow over peach is olive. Here every
/// stop is a shade of the halo: a deeper coral at the corner, the halo
/// itself, its pale edge, the page — and the second circle leans toward rose
/// (−20°), never toward yellow.
///
/// [variant] moves the circles as the shared field does (the trimester).
class PregField extends StatelessWidget {
  const PregField({super.key, required this.ground, this.variant = 1, this.glowAt = 0.42});
  final Color ground;
  final int variant;

  /// Kept on the signature for the plain-gradient version (revert); the
  /// composition places its own circles.
  final double glowAt;

  @override
  Widget build(BuildContext context) => RepaintBoundary(
        child: CustomPaint(painter: _PregFieldPainter(ground, variant), size: Size.infinite),
      );
}

class _PregFieldPainter extends CustomPainter {
  const _PregFieldPainter(this.ground, this.phase);
  final Color ground;
  final int phase;

  @override
  void paint(Canvas canvas, Size size) {
    final halo = HSLColor.fromColor(kPregHalo); // ≈ 17°, the painted halo
    // The four stops, all of the halo's family: coral → halo → edge → page.
    final deep = halo.withSaturation(0.88).withLightness(0.80).toColor();
    final mid = kPregHalo;
    final pale = kPregHaloEdge;
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = ui.Gradient.linear(
          Offset(size.width, 0),
          Offset(0, size.height * 0.62),
          [deep, mid, pale, ground],
          [0.0, 0.34, 0.78, 1.0],
        ),
    );
    final t = (phase % 6) / 6.0;
    // The white circle, top right — the same object as the shared field's.
    canvas.drawCircle(
      Offset(size.width * (0.82 - t * 0.30), -size.height * (0.22 + t * 0.16)),
      size.width * (0.95 + t * 0.30),
      Paint()..color = Colors.white.withValues(alpha: 0.26),
    );
    // The second circle leans to rose, not yellow.
    final rose = halo.withHue((halo.hue - 20 + 360) % 360).withSaturation(0.72).withLightness(0.87).toColor();
    canvas.drawCircle(
      Offset(size.width * (0.10 + t * 0.5), size.height * (0.74 - t * 0.14)),
      size.width * (0.62 + (1 - t) * 0.26),
      Paint()..color = rose.withValues(alpha: 0.5),
    );
    final dot = Paint()..color = Colors.white.withValues(alpha: 0.030);
    for (double y = 6; y < size.height * 0.80; y += 9) {
      for (double x = (y ~/ 9).isEven ? 6 : 10.5; x < size.width; x += 9) {
        canvas.drawCircle(Offset(x, y), 1.15, dot);
      }
    }
  }

  @override
  bool shouldRepaint(_PregFieldPainter old) => old.ground != ground || old.phase != phase;
}

// KEPT FOR REVERT — the plain vertical gradient with a glow (the version the
// user first approved, 2026-09-22): a LinearGradient [kPregHaloEdge,
// kPregHalo, kPregHaloEdge] at [0, 0.45, 1] with a RadialGradient of kPregHalo
// centred at `glowAt`, radius 0.7. "If not, I can revert that change."

/// The 2D figure for [week], with its edge faded to transparent.
String pregBabyArt(int week) => 'assets/baby2d/week_${week.clamp(4, 40).toString().padLeft(2, '0')}.png';

class V3PregHero extends StatefulWidget {
  const V3PregHero({
    super.key,
    required this.p,
    required this.week,
    required this.day,
    required this.selected,
    required this.today,
    required this.daysBack,
    required this.onSelectDay,
    required this.markFor,
    required this.initial,
    this.onDetails,
    this.onAvatar,
    this.onSaved,
  });

  final V2Palette p;
  final int week;

  /// The day of pregnancy (1–280); the title shows the day within the week.
  final int day;

  final DateTime selected;
  final DateTime today;
  final int daysBack;
  final ValueChanged<DateTime> onSelectDay;
  final Widget? Function(DateTime date, bool selected) markFor;

  /// One letter for the avatar.
  final String initial;

  /// The figure and the Details pill — the week page. Null hides the pill.
  final VoidCallback? onDetails;

  /// The avatar. Null: the stage-door menu, as the shared chrome does.
  final VoidCallback? onAvatar;
  final VoidCallback? onSaved;

  static const _months = [
    'January', 'February', 'March', 'April', 'May', 'June',
    'July', 'August', 'September', 'October', 'November', 'December',
  ];

  @override
  State<V3PregHero> createState() => _V3PregHeroState();
}

class _V3PregHeroState extends State<V3PregHero> {
  /// Measured for the stage-door menu — see `V3HeroChrome` for why the key
  /// has to outlive the build.
  final GlobalKey _avatarKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final p = widget.p;
    final now = DateTime.now();
    final sel = widget.selected;
    final dayInWeek = ((widget.day - 1) % 7) + 1;

    return SafeArea(
      bottom: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(18, 10, 18, 16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // ---- avatar · date · saved -----------------------------------------
          //
          // ⚠️ THE SELECTED DAY, NOT `now` (the TTC rule): tap back three days
          // and the date at the top moves with the cards. The year appears
          // only when the selection leaves the current one.
          Row(children: [
            _Round(
              p: p,
              boxKey: _avatarKey,
              semantic: 'You',
              onTap: widget.onAvatar ?? () => showStageDoorMenu(context, _avatarKey),
              child: widget.initial.isEmpty
                  ? Icon(Icons.person_outline_rounded, size: 18, color: p.ink2)
                  : Text(widget.initial.toUpperCase(),
                      style: pvJakarta(fontSize: 14, fontWeight: FontWeight.w700, color: p.ink1)),
            ),
            const Spacer(),
            Text(
                '${sel.day} ${V3PregHero._months[sel.month - 1]}'
                '${sel.year == now.year ? '' : ' ${sel.year}'}',
                style: pvManrope(fontSize: 15, fontWeight: FontWeight.w800, letterSpacing: 0.1, color: p.ink1)),
            const Spacer(),
            _Round(
              p: p,
              semantic: 'Saved',
              onTap: widget.onSaved ?? () {},
              child: Icon(Icons.bookmark_border_rounded, size: 18, color: p.ink2),
            ),
          ]),
          const SizedBox(height: 16),

          // ---- the week ---------------------------------------------------------
          PvDayStrip(
            p: p,
            selected: widget.selected,
            today: widget.today,
            onSelect: widget.onSelectDay,
            // Ink, not coral: the base UI's one accent on a light ground.
            accent: p.ink1,
            keyPrefix: 'preg_day_',
            daysBack: widget.daysBack,
            daysForward: 6,
            markFor: widget.markFor,
          ),

          // ---- the baby this week, in its own glow -------------------------------
          //
          // Flo's disc: the week at the top of it, the figure filling it,
          // Details at its foot. Ours has no edge — the PNG's halo fades into
          // the field, which is the same peach — so the "disc" is the glow
          // the illustrator painted, and the words sit on it.
          Center(
            child: GestureDetector(
              onTap: widget.onDetails,
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 320,
                height: 320,
                child: Stack(alignment: Alignment.center, children: [
                  Positioned.fill(
                    child: Image.asset(pregBabyArt(widget.week),
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.medium,
                        errorBuilder: (_, _, _) => const SizedBox.shrink()),
                  ),
                  Positioned(
                    top: 18,
                    child: Column(children: [
                      Text('Week ${widget.week}',
                          style: pvFraunces(
                              fontSize: 30, letterSpacing: -0.75, fontWeight: FontWeight.w600, height: 1.1, color: p.ink1)),
                      const SizedBox(height: 2),
                      Text('Day $dayInWeek',
                          style: pvManrope(fontSize: 12.5, fontWeight: FontWeight.w800, letterSpacing: 0.6, color: p.ink2)),
                    ]),
                  ),
                  if (widget.onDetails != null)
                    Positioned(
                      bottom: 14,
                      child: Material(
                        color: Colors.white,
                        shape: const StadiumBorder(),
                        clipBehavior: Clip.antiAlias,
                        elevation: 0,
                        child: InkWell(
                          onTap: widget.onDetails,
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(18, 9, 18, 9),
                            child: Text('Details',
                                style: pvManrope(fontSize: 13, fontWeight: FontWeight.w800, color: p.ink1)),
                          ),
                        ),
                      ),
                    ),
                ]),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

/// The TTC header's round button, on the field.
class _Round extends StatelessWidget {
  const _Round({required this.p, required this.child, required this.onTap, required this.semantic, this.boxKey});
  final V2Palette p;
  final Widget child;
  final VoidCallback onTap;
  final String semantic;
  final Key? boxKey;

  @override
  Widget build(BuildContext context) => Semantics(
        button: true,
        label: semantic,
        child: InkWell(
          key: boxKey,
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: p.surface.withValues(alpha: 0.85),
              shape: BoxShape.circle,
              border: Border.all(color: p.line),
            ),
            child: child,
          ),
        ),
      );
}

/// The white sheet the rest of the home rides on, over the field — TTC's
/// `_Sheet`, with the same bottom clearance for the nav and the Ask FAB.
class V3PregSheet extends StatelessWidget {
  const V3PregSheet({super.key, required this.p, required this.children, this.bottomClearance = 150});
  final V2Palette p;
  final List<Widget> children;
  final double bottomClearance;

  @override
  Widget build(BuildContext context) => Container(
        constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height * 0.72),
        decoration: BoxDecoration(
          color: p.ground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 24, offset: const Offset(0, -6)),
          ],
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          ...children,
          SizedBox(height: bottomClearance),
        ]),
      );
}

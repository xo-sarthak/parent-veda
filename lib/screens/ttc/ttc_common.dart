// =============================================================================
//  TTC - shared styling & building blocks
// -----------------------------------------------------------------------------
//  Self-contained styling for the Trying-to-Conceive stage, kept inside the ttc
//  module so nothing here depends on the pregnancy or parenting screens. The
//  three stages stay code-isolated and agree only on VALUES.
//
//  The palette is intentionally IDENTICAL to the other two stages, hex for hex.
//  That is not laziness - it is the product requirement:
//
//      "The shell remains identical. Floating pill navigation remains
//       identical. Visual rhythm remains identical. The difference lies only
//       in content."                                    - TTC master, §2.3
//
//  The parenting app learned this the expensive way: the colours were already
//  the same and the two apps still felt different, because every screen
//  hand-rolled its own card. So the shared card shell, the 18px gutter and the
//  ink-lift shadow below are the parts that actually carry the continuity.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../services/app_shell.dart';
import '../../ttc/ttc_chapter.dart';
import '../../widgets/global_ask_fab.dart';
import 'ttc_calendar_screen.dart';
import 'ttc_community_screen.dart';
import 'ttc_prepare_screen.dart';
import 'ttc_profile_screen.dart';
import 'ttc_strings.dart';
import 'ttc_today_screen.dart';
import 'ttc_tools_screen.dart';

// ---- palette (same hexes as pregnancy & parenting) --------------------------
const Color ttcBg = Color(0xFFFBF9FE);
const Color ttcInk = Color(0xFF2F2C30);
const Color ttcSoft = Color(0xFF69636C);
const Color ttcPurple = Color(0xFF6A30B6);

/// The far end of every TTC gradient.
///
/// Gradients here used to run purple → a LIGHTER purple, and twice all the way
/// to coral, which is what made TTC's cards read pink beside pregnancy's. The
/// pregnancy hero runs primary500 → primary700 - toward the deeper shade - so
/// every purple surface in this stage does the same.
///
/// One constant rather than a hex repeated in seven files, so the next card
/// cannot quietly pick its own.
const Color ttcPurpleDeep = Color(0xFF4A1C86);
const Color ttcCoral = Color(0xFFFF5A79);
const Color ttcPanel = Color(0xFFF3EEF7);
const Color ttcMuted = Color(0xFFA99CBB);
const Color ttcBorder = Color(0xFFE7DFEE);
const Color ttcLine = Color(0xFFE4E2E5);
const Color ttcBrown = Color(0xFF7A4600);
const Color ttcCoralTint = Color(0xFFFFF0F3);
const Color ttcTitleInk = Color(0xFF2D144C);

// ---- the partner's palette - "Slate" ----------------------------------------
//  A deliberate counterpart rather than a recolour, carried over from the
//  pregnancy father mode hex for hex so a man who pairs during TTC and stays
//  through pregnancy never sees his half of the product change colour.
//
//  Structure, components and spacing stay byte-identical to hers. Only colour
//  and the header font change - which is what keeps the two recognisably one
//  product rather than two apps.
const Color ttcSlateBg = Color(0xFFF4EFE8);
const Color ttcSlateInk = Color(0xFF22333B);
const Color ttcSlate = Color(0xFF2E5266);

/// His half had the identical construction error - a gradient running toward a
/// LIGHTER shade. Fixed alongside hers so the two stay mirror images.
const Color ttcSlateDeep = Color(0xFF1C3A4A);
const Color ttcSlateAmber = Color(0xFFE0915B);
const Color ttcSlatePanel = Color(0xFFEAE3D9);
const Color ttcSlateSoft = Color(0xFF6B7A81);
const Color ttcSlateLine = Color(0xFFDDD4C7);

/// Shared geometry. The gutter matched to 18 and the radius to 26 are the two
/// numbers that made the parenting app stop reading as a second product.
const double ttcGutter = 18;
const double ttcCardRadius = 26;

/// The "ink lift" - a barely-there lavender-tinted shadow. Never a purple glow.
const List<BoxShadow> ttcCardShadow = [
  BoxShadow(color: Color(0x142D144C), blurRadius: 22, offset: Offset(0, 8)),
];

/// Leaves room for the floating pill nav so the last card is never trapped
/// underneath it.
///
/// It used to be 108 - sized for the nav pill alone, and the nav pill was the
/// only floating thing anyone had thought about. The Ask Veda FAB floats over
/// every route from `MaterialApp.builder`, so it is in no screen's layout at
/// all, and the last rows of sixteen screens sat under it: a delete ×, a Join
/// button, a ₹599 price. `kAskFabReserve` is the taller of the two, so one
/// constant covers both.
///
/// One constant, not two, and it applies to PUSHED screens as well. Those have
/// no nav pill, which is how thirty of them ended up hardcoding `40` - correct
/// for the pill they did not have, wrong for the FAB they did.
const double ttcBottomInset = kAskFabReserve;

// ---- text -------------------------------------------------------------------
//  Three fonts, three jobs - Fraunces for hero moments only, Jakarta for
//  titles, Manrope for everything the eye actually reads.

TextStyle ttcFraunces(double size,
        {FontWeight w = FontWeight.w400,
        Color color = ttcInk,
        double h = 1.12}) =>
    GoogleFonts.fraunces(
        fontSize: size,
        fontWeight: w,
        height: h,
        letterSpacing: -0.4,
        color: color);

TextStyle ttcJakarta(double size,
        {FontWeight w = FontWeight.w700, Color color = ttcTitleInk}) =>
    GoogleFonts.plusJakartaSans(fontSize: size, fontWeight: w, color: color);

TextStyle ttcBody(double size,
        {Color color = ttcSoft,
        double h = 1.6,
        FontWeight w = FontWeight.w400}) =>
    GoogleFonts.manrope(fontSize: size, height: h, color: color, fontWeight: w);

// ---- small parts ------------------------------------------------------------

Widget ttcEyebrow(String t, {Color color = ttcCoral, double spacing = 1.4}) =>
    Text(
      t.toUpperCase(),
      style: GoogleFonts.manrope(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: spacing,
          color: color),
    );

Widget ttcDivider() => Container(height: 1, color: ttcLine);

/// A body paragraph that shows a few lines and opens in place.
///
/// The home screens on the other two stages cap almost everything — parenting's
/// caps text in fourteen places and follows each with "Explore Brain ›" or
/// "Read more →". TTC's Today did it in five, and five of its nine cards
/// printed their body uncapped, which is why it read as a wall of text where
/// the others read as a menu.
///
/// The obvious fix — cap everything — only works where there is somewhere for
/// the rest to live. Rhythm has the Cycle Companion behind it and Nutrition has
/// the Planner, so those cap and link. Today's movement and the myth have no
/// detail screen at all, and capping them would simply delete the second half
/// of a paragraph nobody could then reach.
///
/// So this is the third option: the content stays on the card and stays out of
/// the way. **You can only hide what has somewhere to go** — and where it does
/// not, "hidden" has to mean one tap, not gone.
class TtcExpandableText extends StatefulWidget {
  const TtcExpandableText({
    super.key,
    required this.text,
    required this.t,
    this.lines = 2,
    this.style,
  });

  final String text;
  final TtcS t;

  /// How much shows before the fold. Two lines is enough to decide whether the
  /// rest is worth opening, which is the only job the preview has.
  final int lines;
  final TextStyle? style;

  @override
  State<TtcExpandableText> createState() => _TtcExpandableTextState();
}

class _TtcExpandableTextState extends State<TtcExpandableText> {
  bool _open = false;

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? ttcBody(13, h: 1.55);
    return LayoutBuilder(builder: (context, box) {
      // Only offer the control when there is genuinely something behind it. A
      // "More" that reveals nothing is worse than no control at all.
      final painter = TextPainter(
        text: TextSpan(text: widget.text, style: style),
        maxLines: widget.lines,
        textDirection: TextDirection.ltr,
      )..layout(maxWidth: box.maxWidth);
      final overflows = painter.didExceedMaxLines;

      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(
          widget.text,
          style: style,
          maxLines: _open ? null : widget.lines,
          overflow: _open ? TextOverflow.visible : TextOverflow.ellipsis,
        ),
        if (overflows) ...[
          const SizedBox(height: 7),
          GestureDetector(
            onTap: () => setState(() => _open = !_open),
            behavior: HitTestBehavior.opaque,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              Text(_open ? widget.t.showLess : widget.t.showMore,
                  style:
                      ttcBody(12, color: ttcPurple, w: FontWeight.w700)),
              const SizedBox(width: 2),
              Icon(_open ? Icons.expand_less_rounded : Icons.expand_more_rounded,
                  size: 17, color: ttcPurple),
            ]),
          ),
        ],
      ]);
    });
  }
}

/// The section title used above every block on every TTC screen.
Widget ttcSectionTitle(String title, {String? eyebrow, Widget? trailing}) =>
    Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (eyebrow != null) ...[
                  ttcEyebrow(eyebrow),
                  const SizedBox(height: 6),
                ],
                Text(title, style: ttcJakarta(17.5)),
              ],
            ),
          ),
          ?trailing,
        ],
      ),
    );

/// The one card shell. Every TTC surface uses this - no screen hand-rolls its
/// own, which is the whole reason the stages look like one product.
class TtcCard extends StatelessWidget {
  const TtcCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(18),
    this.onTap,
    this.color = Colors.white,
    this.border,
  });

  final Widget child;
  final EdgeInsets padding;
  final VoidCallback? onTap;
  final Color color;
  final Color? border;

  @override
  Widget build(BuildContext context) {
    final card = Container(
      width: double.infinity,
      padding: padding,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(ttcCardRadius),
        boxShadow: ttcCardShadow,
        border: border == null ? null : Border.all(color: border!),
      ),
      child: child,
    );
    if (onTap == null) return card;
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: card,
    );
  }
}

/// The empty state. Not a blank space and not a hidden section - the invitation
/// IS the feature's advertisement.
///
///     "A feature is never hidden. Every section renders even when empty; only
///      the empty copy changes."          - Product Reference, rule §12.1.2
class TtcEmpty extends StatelessWidget {
  const TtcEmpty({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
    this.cta,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String body;
  final String? cta;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return TtcCard(
      onTap: onTap,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 42,
          height: 42,
          alignment: Alignment.center,
          decoration: const BoxDecoration(color: ttcPanel, shape: BoxShape.circle),
          child: Icon(icon, size: 21, color: ttcPurple),
        ),
        const SizedBox(height: 13),
        Text(title, style: ttcJakarta(15.5)),
        const SizedBox(height: 6),
        Text(body, style: ttcBody(13.5)),
        if (cta != null) ...[
          const SizedBox(height: 13),
          Row(children: [
            Text(cta!, style: ttcBody(13, color: ttcPurple, w: FontWeight.w800)),
            const SizedBox(width: 5),
            const Icon(Icons.arrow_forward_rounded, size: 15, color: ttcPurple),
          ]),
        ],
      ]),
    );
  }
}

// ---- fertility colour language ---------------------------------------------
//  Deliberately a single warm family - never green-to-red. A traffic light
//  turns a fertile day into a deadline and a low day into a failure, which is
//  precisely the emotional posture this stage is built to avoid.
//
//  Intensity carries the meaning instead of hue, which also means the reading
//  survives colour blindness and a greyscale screenshot.

Color ttcFertilityTint(FertilityLevel f) {
  switch (f) {
    case FertilityLevel.low:
      return ttcPanel;
    case FertilityLevel.medium:
      return const Color(0xFFF6ECFA);
    case FertilityLevel.high:
      return ttcCoralTint;
    case FertilityLevel.peak:
      return const Color(0xFFFFE3EA);
  }
}

Color ttcFertilityInk(FertilityLevel f) =>
    f == FertilityLevel.low ? ttcSoft : ttcCoral;

/// Diagonal-striped placeholder standing in for imagery and video until real
/// media exists. The same convention the parenting module uses, so a missing
/// asset reads as "not shot yet" rather than as a broken image.
class TtcStriped extends StatelessWidget {
  const TtcStriped({
    super.key,
    required this.height,
    this.width,
    this.radius = 16,
    this.child,
  });

  final double height;
  final double? width;
  final double radius;
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius),
      child: CustomPaint(
        painter: _TtcStripePainter(),
        child: SizedBox(
          height: height,
          width: width ?? double.infinity,
          child: child,
        ),
      ),
    );
  }
}

class _TtcStripePainter extends CustomPainter {
  static const double band = 11;
  static const Color a = Color(0xFFEFE7F5);
  static const Color b = Color(0xFFF6F0FA);

  @override
  void paint(Canvas canvas, Size size) {
    canvas.drawRect(Offset.zero & size, Paint()..color = b);
    final p = Paint()
      ..color = a
      ..strokeWidth = band
      ..style = PaintingStyle.stroke;
    for (double d = -size.height; d < size.width + size.height; d += band * 2) {
      canvas.drawLine(Offset(d, 0), Offset(d + size.height, size.height), p);
    }
  }

  @override
  bool shouldRepaint(covariant _TtcStripePainter old) => false;
}

/// Shown instead of a calendar fertility reading when a clinic is running the
/// cycle (IVF / IUI / ovulation induction / FET).
///
/// The engine already refuses to publish an ovulation day or fertility grade on
/// these paths, so this card exists to say WHY - otherwise the surfaces fall
/// back to "we are still learning your rhythm", which is untrue here. We are not
/// learning. We are deferring to her doctor on purpose.
class TtcClinicLedCard extends StatelessWidget {
  const TtcClinicLedCard({super.key, required this.t, required this.pathLabel});

  final TtcS t;

  /// Named back to her so the card is obviously a consequence of something she
  /// told us, and so a wrong answer is visibly correctable.
  final String pathLabel;

  @override
  Widget build(BuildContext context) {
    return TtcCard(
      color: const Color(0xFFFDF6EC),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.local_hospital_outlined, size: 18, color: ttcBrown),
          const SizedBox(width: 9),
          Expanded(
            child: Text(t.clinicLedTitle,
                style: ttcJakarta(15.5, color: ttcBrown)),
          ),
        ]),
        const SizedBox(height: 11),
        Text(t.clinicLedBody, style: ttcBody(13.5, color: ttcBrown, h: 1.6)),
        const SizedBox(height: 12),
        ttcDivider(),
        const SizedBox(height: 11),
        Text(t.clinicLedStillUseful,
            style: ttcBody(12.5, color: ttcBrown, h: 1.5)),
        const SizedBox(height: 10),
        Text(t.clinicLedPath(pathLabel),
            style: ttcBody(11.5, color: ttcMuted, w: FontWeight.w700)),
      ]),
    );
  }
}

/// The honest note used wherever a surface is genuinely not built yet.
///
///     "Be honest about what is not built - 'link coming' rather than a dead
///      button."                            - Product Reference, rule §12.2.10
class TtcBuilding extends StatelessWidget {
  const TtcBuilding({
    super.key,
    required this.t,
    required this.detail,
    required this.detailHi,
  });

  final TtcS t;
  final String detail;
  final String detailHi;

  @override
  Widget build(BuildContext context) {
    return TtcCard(
      color: ttcPanel,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ttcEyebrow(t.beingBuilt, color: ttcPurple),
        const SizedBox(height: 9),
        Text(t.hinglish ? detailHi : detail, style: ttcBody(13.5, h: 1.55)),
      ]),
    );
  }
}

/// The one "not yet" affordance. A tap always acknowledges itself - a control
/// that silently does nothing reads as a bug, which is worse than honesty.
void ttcSoon(BuildContext context, String what) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('$what — ${TtcS.current().comingSoon}'),
      behavior: SnackBarBehavior.floating,
    ),
  );
}

/// A horizontal progress bar. The app-wide replacement for percentage rings.
class TtcProgressBar extends StatelessWidget {
  const TtcProgressBar({
    super.key,
    required this.value,
    this.height = 6,
    this.track = const Color(0x33FFFFFF),
    this.fill = Colors.white,
  });

  final double value; // 0..1
  final double height;
  final Color track;
  final Color fill;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(999),
      child: SizedBox(
        height: height,
        child: Stack(children: [
          Container(color: track),
          FractionallySizedBox(
            widthFactor: value.clamp(0.0, 1.0),
            child: Container(color: fill),
          ),
        ]),
      ),
    );
  }
}

// ---- navigation -------------------------------------------------------------
//  The TTC shell is a pushed route anchored at 'ttc/today', exactly like the
//  parenting app is anchored at 'pp/my_child'. Popping back to the anchor
//  before pushing keeps the stack shallow no matter how deep a tool goes.

const String ttcHomeRoute = 'ttc/today';

/// Central tab navigation for the TTC stage.
void openTtcTab(BuildContext context, int index) {
  final nav = Navigator.of(context);
  nav.popUntil((r) => r.isFirst || r.settings.name == ttcHomeRoute);
  switch (index) {
    case 1:
      nav.push(MaterialPageRoute<void>(
          builder: (_) => const TtcPrepareScreen(),
          settings: const RouteSettings(name: 'ttc/prepare')));
      break;
    case 2:
      nav.push(MaterialPageRoute<void>(
          builder: (_) => const TtcToolsScreen(),
          settings: const RouteSettings(name: 'ttc/tools')));
      break;
    case 3:
      nav.push(MaterialPageRoute<void>(
          builder: (_) => const TtcCalendarScreen(),
          settings: const RouteSettings(name: 'ttc/calendar')));
      break;
    case 4:
      nav.push(MaterialPageRoute<void>(
          builder: (_) => const TtcCommunityScreen(),
          settings: const RouteSettings(name: 'ttc/community')));
      break;
    // 0 = Today: the popUntil above already returned to it.
  }
}

/// Opens the TTC stage from anywhere (the doorway on the pregnancy Home).
void openTtc(BuildContext context) {
  Navigator.of(context).push(MaterialPageRoute<void>(
    builder: (_) => const TtcTodayScreen(),
    settings: const RouteSettings(name: ttcHomeRoute),
  ));
}

/// Leaves TTC for the pregnancy shell. The one exit from this stage, shared by
/// the positive test and the Profile's stage switch.
///
/// There are two stacks underneath a caller and they need opposite treatment:
///
///   * **entered through the door on the pregnancy Home** - the pregnancy shell
///     is still alive at the bottom of the stack. Popping to it is not just
///     enough, it is BETTER than rebuilding: her tab, her scroll position and
///     her controllers are all still there.
///   * **booted straight here by the splash** - `ttc/today` IS the first route.
///     There is nothing behind it, so a pop lands exactly where it started. This
///     is the case that read as a dead button.
///
/// So: pop first, then look at what we landed on. `popUntil`'s predicate runs
/// against the top route as the stack unwinds, so the last route it sees is the
/// first route - which tells us which of the two stacks we were in without
/// having to be told.
///
/// Returns false only when we are in the second case and no shell is registered
/// (a widget test, or a build where `main.dart` has not run), so the caller can
/// say something true rather than appear to do nothing.
bool leaveTtcForPregnancy(NavigatorState nav) {
  var ttcWasRoot = false;
  nav.popUntil((r) {
    if (r.isFirst) {
      ttcWasRoot = r.settings.name == ttcHomeRoute;
      return true;
    }
    return false;
  });
  if (!ttcWasRoot) return true; // the live pregnancy shell is back on screen
  return AppShell.openPregnancy(nav);
}

/// The floating pill tab bar. Same five destinations as the pregnancy app, same
/// component shape - active tab expands into a filled pill with icon AND label,
/// so the parent always knows what each tab is.
class TtcBottomNav extends StatelessWidget {
  const TtcBottomNav({super.key, required this.active, this.slate = false});

  /// 0 = Today · 1 = Prepare · 2 = Tools · 3 = Calendar · 4 = Community
  final int active;

  /// The partner's palette. Same five destinations, his colours.
  ///
  /// Deliberately NOT a reduced tab set. Per-user navigation is forbidden -
  /// personalisation changes content, ranking and order, never structure - and
  /// the father shell in pregnancy follows the same rule: one scaffold, his
  /// content inside it.
  final bool slate;

  /// Icons only. The labels used to be hardcoded English here, so the one part
  /// of the stage visible on EVERY screen was the one part that never
  /// translated - the whole app in Hinglish with an English nav under it.
  static const List<IconData> _icons = [
    Icons.home_rounded,
    Icons.school_rounded,
    Icons.widgets_rounded,
    Icons.calendar_today_rounded,
    Icons.groups_rounded,
  ];

  static List<String> _labels(TtcS t) =>
      [t.tabToday, t.tabPrepare, t.tabTools, t.tabCalendar, t.tabCommunity];

  void _tap(BuildContext context, int i) {
    if (i == active) return;
    openTtcTab(context, i);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: const [
          BoxShadow(
              color: Color(0x292D144C), blurRadius: 28, offset: Offset(0, 8))
        ],
      ),
      child: Row(children: [
        for (int i = 0; i < _icons.length; i++) _item(context, i)
      ]),
    );
  }

  Widget _item(BuildContext context, int i) {
    final on = i == active;
    final t = TtcS.current();
    final icon = _icons[i];
    final label = _labels(t)[i];
    final child = GestureDetector(
      onTap: () => _tap(context, i),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOut,
        padding:
            EdgeInsets.symmetric(horizontal: on ? 12 : 4, vertical: on ? 9 : 6),
        decoration: BoxDecoration(
          color: on ? (slate ? ttcSlate : ttcPurple) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
        ),
        child: on
            ? Row(mainAxisSize: MainAxisSize.min, children: [
                Icon(icon, size: 21, color: Colors.white),
                const SizedBox(width: 6),
                Text(label,
                    style: ttcBody(12.5, color: Colors.white, w: FontWeight.w700)),
              ])
            : Column(mainAxisSize: MainAxisSize.min, children: [
                // The ACTIVE pill was made slate for him and the four inactive
                // tabs were left on `ttcMuted` - which is 0xFFA99CBB, a
                // lavender grey. It reads as neutral on her near-white
                // background and unmistakably as HER PURPLE on his warm cream
                // one. So four of his five tabs were tinted the other app's
                // colour, on every screen of his half.
                //
                // A muted tone is never neutral in the abstract; it is neutral
                // against the background it was chosen for.
                Icon(icon, size: 20, color: slate ? ttcSlateSoft : ttcMuted),
                const SizedBox(height: 3),
                Text(label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                    style: ttcBody(8.5,
                        color: slate ? ttcSlateSoft : ttcMuted,
                        w: FontWeight.w600)),
              ]),
      ),
    );
    // The active pill sizes to its content; the four inactive tabs share the
    // rest evenly so the row cannot overflow under a large text scale.
    return on ? child : Expanded(child: child);
  }
}

/// The page shell every TTC tab sits in, so all five are structurally identical
/// and no screen re-invents the scroll, the gutter or the nav inset.
class TtcPage extends StatefulWidget {
  const TtcPage({
    super.key,
    required this.tab,
    required this.children,
    this.header,
    this.overlay,
    this.slate = false,
  });

  /// Renders the partner's palette instead of hers.
  final bool slate;

  final int tab;
  final List<Widget> children;

  /// Rendered above the scroll content, inside the same gutter.
  final Widget? header;

  /// Floated bottom-right above the nav pill. Used only by the dev-only
  /// Her | Him switch today.
  final Widget? overlay;

  @override
  State<TtcPage> createState() => _TtcPageState();
}

class _TtcPageState extends State<TtcPage> {
  @override
  void initState() {
    super.initState();
    // The global Ask Veda FAB only appears once something marks the app "live",
    // and normally that is MainScaffold's initState. A TTC user booted straight
    // here by the splash never passes through MainScaffold, so without this the
    // FAB would never appear for her at all.
    //
    // Deferred one frame: the FAB is mounted by MaterialApp.builder, ABOVE this
    // in the tree, so notifying from initState marks an ancestor dirty
    // mid-build - the same "setState() called during build" crash MainScaffold
    // hit on every cold start.
    WidgetsBinding.instance
        .addPostFrameCallback((_) => FabState.instance.markAppLive());
  }

  @override
  Widget build(BuildContext context) {
    final tab = widget.tab;
    final header = widget.header;
    final overlay = widget.overlay;
    final children = widget.children;
    return Scaffold(
      backgroundColor: widget.slate ? ttcSlateBg : ttcBg,
      body: Stack(children: [
        Positioned.fill(
          child: SafeArea(
            bottom: false,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                  ttcGutter, 8, ttcGutter, ttcBottomInset),
              children: [
                if (header != null) ...[header, const SizedBox(height: 18)],
                ...children,
              ],
            ),
          ),
        ),
        if (overlay != null) Positioned(right: 14, bottom: 96, child: overlay),
        Positioned(
          left: 14,
          right: 14,
          bottom: 14,
          child: SafeArea(
              top: false,
              child: TtcBottomNav(active: tab, slate: widget.slate)),
        ),
      ]),
    );
  }
}

/// The standard header: mark, wordmark, then the utility row. Mirrors the
/// pregnancy Home's brand header so the two never read as different apps.
///
/// The utility row was documented from the start and left empty, which is how
/// the stage ended up with no way to reach a language control or a sign-out.
/// The profile entry is now part of the header itself rather than something
/// each tab remembers to pass, so no tab can be the one that forgets.
class TtcHeader extends StatelessWidget {
  const TtcHeader({super.key, this.trailing, this.slate = false});

  final Widget? trailing;

  /// His palette.
  ///
  /// The profile door was added to fix A-2/A-3/A-61 — no language control, no
  /// sign-out, no way to correct anything — and it was added to HER header
  /// only. His half rolled its own logo-and-nothing row, so the sealed room
  /// those findings describe stayed sealed on his side: a paired partner had no
  /// way to switch to Hinglish and no way to sign out, on any screen.
  ///
  /// One header with a palette flag, rather than two headers. Two headers is
  /// how his came to be missing the door in the first place.
  final bool slate;

  @override
  Widget build(BuildContext context) {
    final ink = slate ? ttcSlate : ttcPurple;
    return Row(children: [
      Image.asset('assets/brand/pv-mark.png', height: 30),
      const SizedBox(width: 9),
      Text(
        'ParentVeda',
        style: GoogleFonts.plusJakartaSans(
          fontSize: 19,
          fontWeight: FontWeight.w800,
          color: ink,
          letterSpacing: -0.5,
        ),
      ),
      const Spacer(),
      ?trailing,
      ...[
        if (trailing != null) const SizedBox(width: 10),
        GestureDetector(
          onTap: () => openTtcProfile(context),
          behavior: HitTestBehavior.opaque,
          child: Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: slate ? ttcSlatePanel : ttcPanel,
                shape: BoxShape.circle),
            child: Icon(Icons.person_outline_rounded, size: 19, color: ink),
          ),
        ),
      ],
    ]);
  }
}

/// The chapter stepper, drawn to the same silhouette as pregnancy's
/// TrimesterProgressBar so the two heroes read as one component.
///
/// One difference, and it is deliberate: the segments do NOT accumulate.
/// Pregnancy fills T1, then T2, then T3, because a pregnancy only moves
/// forward. Chapters 2-4 here come round with every cycle, so a bar that
/// filled to 80% and then dropped back to 40% would say "you lost ground" on
/// the morning a period arrives - the exact feeling the Journey Map's "not a
/// step backwards" line exists to prevent.
///
/// So only the CURRENT segment fills, by progress through that chapter. It is a
/// position marker wearing a progress bar's clothes: same shape, no claim about
/// how much of anything is banked.
class TtcChapterBar extends StatelessWidget {
  const TtcChapterBar({super.key, required this.today});

  final TtcToday today;

  @override
  Widget build(BuildContext context) {
    final current = today.chapter.index;
    final frac = today.chapterProgress;
    const track = Color(0x38FFFFFF);

    Widget segment(int i) {
      final active = i == current;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: i == TtcChapter.values.length - 1 ? 0 : 6),
          child: Stack(children: [
            Container(
              height: 8,
              decoration: BoxDecoration(
                color: track,
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            if (active)
              FractionallySizedBox(
                widthFactor: frac.clamp(0.04, 1.0),
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
          ]),
        ),
      );
    }

    Widget label(int i) {
      final active = i == current;
      return Expanded(
        child: Padding(
          padding: EdgeInsets.only(right: i == TtcChapter.values.length - 1 ? 0 : 6),
          child: Text('${i + 1}',
              textAlign: TextAlign.center,
              style: ttcBody(10.5,
                  color: Colors.white.withValues(alpha: active ? 1 : 0.55),
                  w: active ? FontWeight.w900 : FontWeight.w700)),
        ),
      );
    }

    return Column(children: [
      Row(children: [for (var i = 0; i < TtcChapter.values.length; i++) segment(i)]),
      const SizedBox(height: 6),
      Row(children: [for (var i = 0; i < TtcChapter.values.length; i++) label(i)]),
    ]);
  }
}

/// The circular hero shortcut, matching pregnancy's Baby / Mother / What's next.
///
/// 44px, a translucent white fill and a lighter border - TTC had rounded
/// squares, which is a small difference that made the two heroes read as
/// different components at a glance.
class TtcHeroShortcut extends StatelessWidget {
  const TtcHeroShortcut({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(children: [
          Container(
            width: 44,
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withValues(alpha: 0.28)),
            ),
            child: Icon(icon, size: 21, color: Colors.white),
          ),
          const SizedBox(height: 6),
          Text(label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: ttcBody(11,
                  color: Colors.white.withValues(alpha: 0.95),
                  w: FontWeight.w700)),
        ]),
      ),
    );
  }
}

/// The one estimates disclaimer, shared.
///
/// It lived privately inside the cycle tools, which is how Today - the screen
/// with the most traffic and the least reliable number - ended up carrying no
/// caveat at all. One widget and one string means that cannot happen again.
class TtcDisclaimer extends StatelessWidget {
  const TtcDisclaimer({super.key, required this.t});

  final TtcS t;

  @override
  Widget build(BuildContext context) {
    return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      const Icon(Icons.info_outline_rounded, size: 15, color: ttcMuted),
      const SizedBox(width: 9),
      Expanded(
        child: Text(t.estimatesDisclaimer,
            style: ttcBody(11.5, color: ttcMuted, h: 1.5)),
      ),
    ]);
  }
}

/// A back bar for pages pushed on top of a tab.
class TtcBackBar extends StatelessWidget {
  const TtcBackBar({super.key, required this.title, this.trailing});

  final String title;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    // A bare arrow, not a chip.
    //
    // TTC had invented a circular grey puck that appears nowhere else: the
    // pregnancy Journey, Profile and reader all use a plain arrow with the
    // title beside it. Ask Veda inside TTC already did too, which read as the
    // odd one out when it was in fact the only screen matching the rest of the
    // app.
    return Row(children: [
      GestureDetector(
        onTap: () => Navigator.of(context).maybePop(),
        behavior: HitTestBehavior.opaque,
        child: const Padding(
          // Keeps a comfortable touch target now the circle is gone.
          padding: EdgeInsets.fromLTRB(2, 8, 14, 8),
          child: Icon(Icons.arrow_back, size: 22, color: ttcTitleInk),
        ),
      ),
      Expanded(child: Text(title, style: ttcJakarta(17))),
      ?trailing,
    ]);
  }
}

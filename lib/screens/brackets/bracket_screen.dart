// =============================================================================
//  BracketScreen — what you see when you open a door
// -----------------------------------------------------------------------------
//  Spec: docs/BRACKET-SCREEN.md. Data: lib/data/brackets/pregnancy_brackets.dart.
//  Audit: docs/BRACKET-AUDIT.md.
//
//  ⚠️ THE ONE RULE THAT SHAPES EVERYTHING: she never sees our vocabulary.
//
//  Content · Activities · Tools · Products · Course · Consult · Extras are the
//  workbook's words — a taxonomy for us to build against, not headings for her
//  to read. A section called "Consult" is a filing cabinet; a section called
//  "Talk to someone" is a door. Two of the headings below are already shipped
//  elsewhere in the app (the brand Premiere page uses "WHAT IT ACTUALLY IS" and
//  "LEARN THIS PROPERLY"), and reusing them beats inventing a second dialect.
//
//  THE ORDER IS FREE FIRST, PAID LAST. Understand → do → track → then buy, learn
//  or book. That is the workbook's own order and it is also the wedge expressed
//  as layout rather than as copy: she knows the price before the pitch because
//  the pitch is at the bottom. A bracket that opened with a product would be the
//  thing 24.3% of Mylo's critical reviews are about.
//
//  ⚠️ THE ABSENT SECTIONS ARE THE DESIGN. Scans & tests renders four sections;
//  Belly & skin care renders two. That unevenness is correct. The instinct to
//  give every bracket the same seven is exactly what manufactures filler, which
//  the workbook's own Read Me names as "the thing that sinks Mylo and iMumz on
//  trust". This is the one place CLAUDE.md's "a feature is never hidden; empty
//  sections render an invitation" is deliberately suspended — because an
//  invitation under Infertility → Products is a shopping prompt beside a
//  clinical grief. `test/bracket_model_test.dart` holds the line.
// =============================================================================

import 'package:flutter/material.dart';

import '../../localization/app_language.dart';
import '../../models/bracket.dart';
import '../../services/bracket_resolver.dart';
import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import '../v2/v3_bracket_art.dart';
import '../v2/v3_skill_art.dart';

/// Her words for our layers. See the header — this map is the rule.
LocalizedText _headingFor(BracketLayer l) => switch (l) {
      BracketLayer.content =>
        const LocalizedText(en: 'What this actually is', hi: 'यह असल में है क्या'),
      BracketLayer.activities =>
        const LocalizedText(en: 'What you can do', hi: 'आप क्या कर सकती हैं'),
      BracketLayer.tools =>
        const LocalizedText(en: 'What you can track', hi: 'क्या ट्रैक कर सकती हैं'),
      // Extras has no generic name on purpose — each entry names itself, because
      // "Extras" tells her nothing and "When the report comes back" tells her
      // everything. Falls back to this only if an entry has no better name.
      BracketLayer.extras =>
        const LocalizedText(en: 'Also here', hi: 'यह भी यहीं'),
      BracketLayer.products =>
        const LocalizedText(en: 'Things that help', hi: 'जो काम आती हैं'),
      BracketLayer.course =>
        const LocalizedText(en: 'Learn this properly', hi: 'इसे ठीक से समझिए'),
      BracketLayer.consult =>
        const LocalizedText(en: 'Talk to someone', hi: 'किसी से बात कीजिए'),
    };

/// Free first, paid last. Not the enum's declaration order — the enum is
/// declared in the workbook's column order, and the workbook puts Products
/// before Course before Consult, which happens to be cheapest-first too.
const List<BracketLayer> _sectionOrder = [
  BracketLayer.content,
  BracketLayer.activities,
  BracketLayer.tools,
  BracketLayer.extras,
  BracketLayer.products,
  BracketLayer.course,
  BracketLayer.consult,
];

/// Only the "Things that help" section carries this, and it is not decoration:
/// stating that prices are visible is the wedge said out loud, so she does not
/// have to discover it.
const _kPricesShown = LocalizedText(en: 'Prices shown', hi: 'क़ीमतें दिख रही हैं');

class BracketScreen extends StatelessWidget {
  const BracketScreen({
    super.key,
    required this.bracket,
    required this.lang,
    required this.labelFor,
    required this.onOpenSurface,
  });

  final Bracket bracket;

  /// Passed in rather than read from a store. This screen has no controller and
  /// should not acquire one — the caller already knows the language, and a
  /// screen that reaches for a singleton to answer one question is a screen that
  /// will reach for two more later.
  final AppLanguage lang;

  /// What a surface is CALLED, or null if this stage cannot open it.
  ///
  /// ⚠️ INJECTED RATHER THAN READ FROM app_structure, and that is what lets this
  /// one screen serve every stage. `app_structure.dart` is pregnancy-shaped —
  /// its homes are today · prepare · tools · calendar · community, which is the
  /// pregnancy tab set. Parenting's tabs are My Child · Brain · Tools ·
  /// Community · Products; TTC's differ again. A screen that asked
  /// `homeFor(id)` directly would silently drop every parenting row on the
  /// floor, because the answer for those ids is null and null looks exactly like
  /// "not available here".
  ///
  /// Returning null is also how a stage says "this surface exists but I cannot
  /// open it" — the row is skipped rather than rendered dead.
  final String? Function(String surfaceId) labelFor;

  /// Routing stays with the caller. This screen knows which surface ids a layer
  /// declares; it deliberately does not know how the app navigates, so it cannot
  /// drift from `home_v3_screen`'s own `_open`.
  final void Function(BuildContext context, String surfaceId) onOpenSurface;

  @override
  Widget build(BuildContext context) {
    final p = V2PaletteStore.instance.current;
    final lang = this.lang;
    final live = _sectionOrder.where((l) => canRender(bracket, l)).toList();

    return Scaffold(
      backgroundColor: p.ground,
      body: CustomScrollView(slivers: [
        SliverAppBar(
          pinned: true,
          backgroundColor: p.ground,
          surfaceTintColor: Colors.transparent,
          foregroundColor: p.ink1,
          elevation: 0,
          expandedHeight: 172,
          flexibleSpace: FlexibleSpaceBar(
            background: _Header(bracket: bracket, p: p, lang: lang),
          ),
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            const SizedBox(height: 20),
            for (final (i, l) in live.indexed) ...[
              // ⚠️ THE STAGGER IS THE POINT, NOT THE FADE. A page where
              // everything appears at once has no reading order; one where each
              // section arrives a beat after the one above it tells the eye
              // where to start. 60ms apart is under the threshold where it
              // reads as waiting — she should feel the order, not the delay.
              //
              // Capped at six steps so a bracket with many live layers never
              // makes the last one arrive late.
              _Enter(
                delayMs: 60 * (i > 5 ? 5 : i),
                child: _Section(
                bracket: bracket,
                layer: l,
                p: p,
                lang: lang,
                labelFor: labelFor,
                onOpenSurface: onOpenSurface,
              ),
              ),
              const SizedBox(height: 26),
            ],
            // No "nothing else here yet" line. The absence IS the statement —
            // adding a note about it would be the empty state the whole model
            // exists to prevent, wearing a different hat.
            const SizedBox(height: 40),
          ]),
        ),
      ]),
    );
  }
}

/// The bracket's hue as a soft field, ITS OWN DRAWN MARK, its title, and the
/// workbook's one line.
///
/// NO PHOTOGRAPH. Forty brackets, no shot list, and a stock photo each is the
/// generic look the whole design brief exists to avoid.
///
/// ⚠️ THE MARK WAS THE MISSING PIECE, AND ITS ABSENCE IS WHY THIS SCREEN READ
/// AS BLANK. This header shipped carrying a hue and nothing else, with a note
/// saying the drawn mark "comes with the doors". The doors have had marks for a
/// while; the note was a debt nobody collected.
///
/// The cost was not decorative. She taps a tile with a crescent moon on it and
/// lands on a page with no moon — so the only thing connecting the two is a
/// pastel, and a pastel alone cannot say WHICH of forty rooms she is standing
/// in. Every bracket screen looked the same because, apart from one hue, every
/// bracket screen WAS the same.
///
/// It is drawn large and low-contrast, bled off the right edge. Big enough to
/// name the room, quiet enough that the title still wins.
class _Header extends StatelessWidget {
  const _Header({required this.bracket, required this.p, required this.lang});
  final Bracket bracket;
  final V2Palette p;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(bracket.hue, p);
    final mark = bracketMarkFor(bracket.id);
    final skill = skillMarkFor(bracket.id);
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [tint, p.ground],
        ),
      ),
      child: Stack(children: [
        // The mark, bled off the right edge and held back to 26%. Off-canvas
        // rather than centred, for the same reason the hero field's arcs are:
        // a shape floating complete in the middle of a field reads as an
        // object sitting ON the page; a shape running off the edge reads as
        // the page itself.
        Positioned(
          right: -34,
          top: 18,
          child: Opacity(
            opacity: 0.26,
            child: SizedBox(
              width: 168,
              height: 168,
              child: skill != null
                  ? V3SkillArt(mark: skill, tint: tint)
                  : mark != null
                      ? V3BracketArt(mark: mark, tint: tint)
                      : const SizedBox.shrink(),
            ),
          ),
        ),
        SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 52, 22, 16),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // The title is width-limited so it never runs under the mark.
              // A headline colliding with its own decoration is the classic
              // failure of a bled background element.
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 250),
                child: Text(bracket.title.of(lang),
                  style: pvFraunces(
                      fontSize: 27,
                      fontWeight: FontWeight.w600,
                      height: 1.15,
                      letterSpacing: -0.6,
                      color: p.ink1)),
              ),
              const SizedBox(height: 7),
              Text(bracket.blurb.of(lang),
                  style:
                      pvManrope(fontSize: 14, height: 1.5, color: p.ink2)),
            ],
          ),
        ),
      ),
      ]),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    required this.bracket,
    required this.layer,
    required this.p,
    required this.lang,
    required this.labelFor,
    required this.onOpenSurface,
  });

  final Bracket bracket;
  final BracketLayer layer;
  final V2Palette p;
  final AppLanguage lang;
  final String? Function(String) labelFor;
  final void Function(BuildContext, String) onOpenSurface;

  @override
  Widget build(BuildContext context) {
    final spec = bracket.layer(layer);
    final ids =
        spec.surfaceIds.where((id) => labelFor(id) != null).toList();
    if (ids.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          // ⚠️ A SHORT RULE IN THE BRACKET'S OWN HUE, not a decorative line.
          // Every section on every bracket used identical grey type, so the
          // page had no colour anywhere below the header — which is most of
          // why forty different rooms looked like one. The rule is the
          // cheapest possible carrier of "you are still inside Sleep".
          Container(
            width: 14,
            height: 2,
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: HSLColor.fromAHSL(1, bracket.hue, 0.42, 0.58).toColor(),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            // The layer's own heading when it has one — Extras always does,
            // because "Also here" is a filing label and "When the report comes
            // back" is the reason she opened this bracket.
            child: Text((spec.heading ?? _headingFor(layer)).of(lang).toUpperCase(),
                style: pvManrope(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                    color: p.ink3)),
          ),
          if (layer == BracketLayer.products)
            Text(_kPricesShown.of(lang).toUpperCase(),
                style: pvManrope(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: p.ink3)),
        ]),
        const SizedBox(height: 10),
        Container(
          clipBehavior: Clip.antiAlias,
          decoration: BoxDecoration(
            color: p.surface,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: p.line),
          ),
          child: Column(children: [
            for (final id in ids) ...[
              _Row(
                  label: labelFor(id)!,
                  p: p,
                  hue: bracket.hue,
                  onTap: () => onOpenSurface(context, id)),
              if (id != ids.last)
                Divider(height: 1, thickness: 1, color: p.line, indent: 35),
            ],
          ]),
        ),
      ]),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(
      {required this.label,
      required this.p,
      required this.hue,
      required this.onTap});
  final String label;
  final double hue;
  final V2Palette p;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      // 56, comfortably over the 44px tap minimum — this is a list of doors and
      // every one of them has to be hittable one-handed.
      child: SizedBox(
        height: 56,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(children: [
            // A small tinted dot per row. Not an icon: we have no art per
            // SURFACE, and inventing forty glyphs to fill a gap is how an icon
            // set stops meaning anything. A dot in the bracket's hue says "this
            // is one of several doors out of this room" and claims nothing
            // more than that.
            Container(
              width: 7,
              height: 7,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: HSLColor.fromAHSL(1, hue, 0.44, 0.60).toColor(),
                shape: BoxShape.circle,
              ),
            ),
            Expanded(
              child: Text(label,
                  style: pvJakarta(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: p.ink1)),
            ),
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}


/// A one-shot fade-and-rise, used to stagger the sections in.
///
/// ⚠️ DELIBERATELY NOT A SCROLL-LINKED ANIMATION. Tying opacity to scroll
/// position means a section can fade back OUT when she scrolls up, which reads
/// as the page losing its place. This plays once, on arrival, and then the page
/// is simply a page.
///
/// `prefers-reduced-motion` has no Flutter equivalent that is reliable across
/// platforms; `MediaQuery.disableAnimationsOf` is the closest and is honoured
/// below, so an accessibility setting removes this rather than shortening it.
class _Enter extends StatefulWidget {
  const _Enter({required this.child, required this.delayMs});
  final Widget child;
  final int delayMs;

  @override
  State<_Enter> createState() => _EnterState();
}

class _EnterState extends State<_Enter> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(
      vsync: this, duration: const Duration(milliseconds: 380));
  late final Animation<double> _a =
      CurvedAnimation(parent: _c, curve: Curves.easeOutCubic);

  @override
  void initState() {
    super.initState();
    Future<void>.delayed(Duration(milliseconds: widget.delayMs), () {
      if (mounted) _c.forward();
    });
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (MediaQuery.disableAnimationsOf(context)) return widget.child;
    return AnimatedBuilder(
      animation: _a,
      builder: (context, child) => Opacity(
        opacity: _a.value,
        // 14px, not 40. A long travel turns an entrance into a performance,
        // and this page is a reference she came to READ.
        child: Transform.translate(
            offset: Offset(0, 14 * (1 - _a.value)), child: child),
      ),
      child: widget.child,
    );
  }
}

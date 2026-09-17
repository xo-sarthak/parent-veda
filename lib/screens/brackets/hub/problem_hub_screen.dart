// =============================================================================
//  ProblemHubScreen — the generic renderer for a HubConfig
// -----------------------------------------------------------------------------
//  PARENTVEDA-PROBLEM-HUB-FINAL-SPEC.md §3, §5.
//
//  ---------------------------------------------------------------------------
//  ⚠️ THE HUB IS A ROUTER, NOT A PAGE. That is the whole of the final spec.
//  ---------------------------------------------------------------------------
//
//  Hero → urgent strip (only if it matters) → "What do you need right now?" →
//  2–4 doors → done. Each door goes straight to its focused destination.
//
//  Three things the earlier build had that the final spec DELETED, each for a
//  stated reason worth keeping so they do not creep back:
//
//    §2.2  The Understand / Check / Talk sections. A hub that asks "what do you
//          need?" and then answers with another category menu has asked the
//          same question twice. She already told us.
//
//    §2.3  The generic "whole picture" situational card. It interrupted the
//          primary task with an informational detour — she came to do a thing,
//          and the first card on the screen was about something else.
//
//    §2.4  Any section rendered because a component exists. A solution appears
//          only when the matrix permits it AND it helps her current intent.
//
//  What remains is short on purpose. A hub that fits on one screen is a hub
//  that answered her.
//
//  ---------------------------------------------------------------------------
//  ⚠️ VISUAL LANGUAGE IS V3's, NOT A NEW ONE — §6.
//  ---------------------------------------------------------------------------
//
//  Same field-and-sheet structure as every V3 home. Doors use the V3 door
//  treatment: a gradient well in the door's hue with a drawn mark, label in
//  Manrope 13/w700 ink2. Buttons are OUTLINED PILLS with a transparent fill and
//  a `p.line` border — the journal section's `_Pill`, which is the app's button.
//
//  ⚠️ NO FILLED VIOLET BUTTONS ANYWHERE. The app's neutrals are lavender-tinted,
//  so a violet fill lands as a third purple on a screen that has already spent
//  its colour budget on the hue wells. The border is what says "button"; the
//  fill was never carrying that job.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../localization/app_language.dart';
import '../../../models/bracket.dart';
import '../../../theme/pv_fonts.dart';
import '../../../widgets/pv_placeholders.dart';
import '../../v2/v2_palette.dart';
import '../../v2/v3_bracket_art.dart';
import '../../v2/v3_hero_field.dart';
import 'hub_config.dart';
import 'hub_intent_art.dart';

class ProblemHubScreen extends StatelessWidget {
  const ProblemHubScreen({
    super.key,
    required this.config,
    required this.bracket,
    required this.lang,
    required this.onSurface,
    required this.onAction,
    this.listenTo,
    this.tools = const [],
  });

  final HubConfig config;
  final Bracket bracket;
  final AppLanguage lang;
  final void Function(BuildContext, String surfaceId) onSurface;
  final void Function(BuildContext, String action) onAction;
  final Listenable? listenTo;

  /// ⚠️ TOOLS BELONG ON THE HUB, NOT BURIED A LEVEL DOWN.
  ///
  /// Feedback: "Move tools out of Help My Child Sleep section and bring it out
  /// on main Sleep section above Talk to Sleep expert." They were living
  /// inside the section screen behind one of the two doors, so a mother who
  /// wanted the sleep log had to first pick the door about a problem she might
  /// not have.
  ///
  /// They sit BETWEEN the doors and the closing offer on purpose. Above the
  /// doors they would compete with the reason she opened the app; below the
  /// consult they would be an afterthought under a paid offer.
  final List<HubTool> tools;

  @override
  Widget build(BuildContext context) {
    // ⚠️ THE CEILING WAS 4 AND THE RECONCILIATION EXCEL OVERRULED IT.
    //
    // The old rule was "§5.3: 2–4 doors. More is a menu, which is what this
    // replaces." The reasoning was sound and the number was not: the hub's job
    // is to ask "what do you need right now?" and the honest number of answers
    // is a property of the PROBLEM, not of the layout. Scans & tests has six
    // real steps, and dropping two of them to hold a ceiling would have removed
    // "see my timeline" and "what happens next?" — the first and last things a
    // mother wants, which is how a journey ends up with no closure.
    //
    // The implementation prompt says it outright: "Do NOT arbitrarily limit
    // this to four. If a hub genuinely has six useful user intents, show six."
    //
    // The floor still matters — one door is not a choice — and a ceiling still
    // exists, because past about eight this stops being a question and becomes
    // the inventory menu the hub was built to replace.
    // ⚠️ ONE DOOR IS LEGAL, AND MEANS "DO NOT SHOW THIS SCREEN".
    //
    // A hub whose single door only restates its tile has nothing to
    // disambiguate, so the tile opens the destination directly and this screen
    // is never built. `hub_registry.dart` does that dispatch; the assert below
    // catches the case where such a config reaches the renderer anyway, which
    // would show a heading and one button — a tap of pure tax.
    assert(config.needs.length >= 2,
        'A one-door hub must open its destination directly — see '
        'hub_registry.dart. Rendering it shows a menu of one.');
    assert(config.needs.length <= 8,
        'A hub asks a question; 2–8 answers. Fewer is not a choice, more is a '
        'menu. The count comes from the problem, never from the grid.');
    assert(config.bracketId == bracket.id);

    return AnimatedBuilder(
      animation: listenTo ?? const AlwaysStoppedAnimation<int>(0),
      builder: (context, _) {
        final p = V2PaletteStore.instance.current;
        final tint = v2BlockTint(bracket.hue, p);
        return Scaffold(
          backgroundColor: p.ground,
          body: Stack(children: [
            // Field is the PAGE's surface and does not scroll; the sheet slides
            // over it. Identical to every V3 home — a gradient that ENDS is
            // what made the old bracket screen read as faded.
            Positioned.fill(
              child: V3HeroField(
                  accent: tint,
                  ground: p.ground,
                  variant: 1,
                  chroma: v3FieldChroma(bracket.hue)),
            ),
            ListView(padding: EdgeInsets.zero, children: [
              _Hero(
                  config: config,
                  bracket: bracket,
                  p: p,
                  lang: lang,
                  tint: tint),
              _Sheet(p: p, children: [
                const SizedBox(height: 20),
                if (config.urgent != null) ...[
                  _pad(_UrgentStrip(
                      urgent: config.urgent!,
                      p: p,
                      lang: lang,
                      onTap: () => onAction(context, config.urgent!.action))),
                  const SizedBox(height: 30),
                ],
                // ⚠️ THE ONLY HEADING ON THE SCREEN. §5.3 — this is the primary
                // navigation, so nothing competes with it.
                _pad(Text(config.needsTitle.of(lang),
                    style: pvFraunces(
                        fontSize: 24,
                        fontWeight: FontWeight.w600,
                        height: 1.18,
                        letterSpacing: -0.55,
                        color: p.ink1))),
                const SizedBox(height: 16),
                _pad(_Doors(
                    config: config,
                    tools: tools,
                    p: p,
                    lang: lang,
                    onSurface: onSurface,
                    onAction: onAction)),
                const SizedBox(height: 30),
              ]),
            ]),
          ]),
        );
      },
    );
  }
}

Widget _pad(Widget child) =>
    Padding(padding: const EdgeInsets.symmetric(horizontal: 18), child: child);

// -----------------------------------------------------------------------------

class _Hero extends StatelessWidget {
  const _Hero(
      {required this.config,
      required this.bracket,
      required this.p,
      required this.lang,
      required this.tint});

  final HubConfig config;
  final Bracket bracket;
  final V2Palette p;
  final AppLanguage lang;
  final Color tint;

  @override
  Widget build(BuildContext context) {
    final mark = bracketMarkFor(bracket.id);

    // ⚠️ A HERO WITH A FILM IN IT CANNOT BE 272dp TALL, AND CANNOT USE A
    // `Spacer` EITHER. This shipped broken and the device said so in yellow
    // stripes: "BOTTOM OVERFLOWED BY 140 PIXELS" on every TTC door.
    //
    // The mechanism is worth keeping, because the obvious fix does not work.
    // The hero was a fixed 272 with a `Spacer()` pushing the eyebrow and title
    // to the bottom; a full-width 16:9 placeholder is about 180dp on top of a
    // back button, an eyebrow and a title, which is 140 more than there is.
    //
    // "So remove the fixed height and let it size to its content" — no. A
    // `Spacer` is a flexible child, and a flexible child inside an unbounded
    // column has nothing to be flexible against, so that trades a visible
    // overflow for a layout assertion. The two have to change together:
    //
    //   · no film → fixed 272, `Spacer`, exactly as pregnancy and parenting
    //     have always rendered it. Byte-identical.
    //   · film    → height driven by the content, `mainAxisSize.min`, and a
    //     plain gap where the `Spacer` was.
    //
    // A computed constant (272 + 140) was the other option and is worse: the
    // number is only right for a one-line hero title, and three of these hubs
    // wrap to two.
    final hasFilm = config.heroVideoSlot != null;

    return SizedBox(
      height: hasFilm ? null : 272,
      child: Stack(children: [
        Positioned(
          right: -26,
          top: 52,
          child: Opacity(
            // 0.5. It was 0.26 and read as two blank grey boxes on the tinted
            // field — a mark you have to look for is decoration nobody sees.
            opacity: 0.5,
            child: SizedBox(
                width: 146,
                height: 146,
                child: mark == null
                    ? const SizedBox.shrink()
                    : V3BracketArt(mark: mark, tint: tint)),
          ),
        ),
        SafeArea(
          bottom: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 22, 20),
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                // Shrink-wrap only when the film is driving the height; the
                // no-film path keeps `max` so the `Spacer` below still has a
                // bounded box to expand into.
                mainAxisSize:
                    hasFilm ? MainAxisSize.min : MainAxisSize.max,
                children: [
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Material(
                      color: Colors.white.withValues(alpha: 0.55),
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: InkWell(
                        onTap: () => Navigator.of(context).maybePop(),
                        child: SizedBox(
                            width: 38,
                            height: 38,
                            child: Icon(Icons.arrow_back_rounded,
                                size: 19, color: p.ink1)),
                      ),
                    ),
                  ),
                  // The `Spacer` is what pushes the title to the foot of a
                  // fixed-height hero. With a film there is no spare height to
                  // distribute and no bounded box to distribute it in, so it
                  // becomes an ordinary gap.
                  if (hasFilm) const SizedBox(height: 20) else const Spacer(),
                  // The bracket name is the eyebrow; the hero is the problem in
                  // her language (§5.1). ink2 on a tinted field — a grey
                  // calibrated for a neutral ground loses contrast on a
                  // chromatic one faster than it loses lightness.
                  Text(bracket.title.of(lang).toUpperCase(),
                      style: pvManrope(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.4,
                          color: p.ink2)),
                  const SizedBox(height: 8),
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 252),
                    child: Text(config.hero.of(lang),
                        style: pvFraunces(
                            fontSize: 27,
                            fontWeight: FontWeight.w600,
                            height: 1.15,
                            letterSpacing: -0.6,
                            color: p.ink1)),
                  ),
                  const SizedBox(height: 9),
                  // ⚠️ THE FILM REPLACES THE LINE, IT DOES NOT JOIN IT. Both
                  // answer "what does this problem area cover", and showing
                  // both doubles the hero's height to carry one fact. The line
                  // is not lost — it becomes the placeholder's subtitle, and
                  // the day a real file lands it is what the thumbnail says.
                  //
                  // ⚠️ NULL ON EVERY NON-TTC HUB, so pregnancy and parenting
                  // render exactly what they rendered before. See the field's
                  // note in `hub_config.dart` for why this is data rather than
                  // a flag the shared screen reads.
                  if (config.heroVideoSlot case final slot?)
                    Padding(
                      padding: const EdgeInsets.only(right: 4, top: 2),
                      child: PvVideoPlaceholder(
                        title: (config.heroVideoTitle ?? config.heroSupport)
                            .of(lang),
                        overlayTitle: true,
                        subtitle: null,
                        hue: bracket.hue,
                        slotId: slot,
                      ),
                    )
                  else
                    ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 300),
                      child: Text(config.heroSupport.of(lang),
                          style: pvManrope(
                              fontSize: 13.5, height: 1.45, color: p.ink2)),
                    ),
                ]),
          ),
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
        // Full height, not 0.72 — see the note in ttc_tool_chrome.dart's sheet.
        constraints: BoxConstraints(minHeight: MediaQuery.sizeOf(context).height),
        decoration: BoxDecoration(
          color: p.ground,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withValues(alpha: 0.10),
                blurRadius: 24,
                offset: const Offset(0, -6)),
          ],
        ),
        child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [...children, const SizedBox(height: 110)]),
      );
}

/// ⚠️ CALM, NOT ALARMING, AND NEVER DISMISSIBLE.
///
/// A red banner on a pregnancy screen is its own harm: it frightens the
/// frightened and numbs everyone else, so by the time it matters nobody reads
/// it. The urgency lives in the POSITION — first, above everything, always —
/// not in the colour.
class _UrgentStrip extends StatelessWidget {
  const _UrgentStrip(
      {required this.urgent,
      required this.p,
      required this.lang,
      required this.onTap});
  final HubUrgent urgent;
  final V2Palette p;
  final AppLanguage lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
        color: p.surface,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 12, 13),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: p.line),
            ),
            child: Row(children: [
              Icon(Icons.emergency_outlined, size: 19, color: p.ink2),
              const SizedBox(width: 11),
              Expanded(
                child: Text(urgent.line.of(lang),
                    style: pvManrope(
                        fontSize: 13.5,
                        height: 1.35,
                        fontWeight: FontWeight.w600,
                        color: p.ink1)),
              ),
              Icon(Icons.chevron_right_rounded, size: 19, color: p.ink3),
            ]),
          ),
        ),
      );
}

/// The 2–4 doors — the hub's primary and very nearly only navigation.
///
/// ⚠️ ROWS, NOT A GRID, AND THIS IS THE ONE PLACE THE V3 HOME'S PATTERN IS
/// DELIBERATELY ADAPTED RATHER THAN COPIED.
///
/// The home's door grid is four columns of 73dp tiles carrying one or two
/// words — "Nutrition", "Symptoms". These doors carry sentences: "Understand my
/// next scan", plus a line of what she gets. At 73dp that wraps to four lines
/// and becomes unreadable.
///
/// So: the same WELL (gradient of the door's hue, drawn mark, 14dp radius) at
/// row scale, with the label beside it instead of under it. Every other token —
/// the gradient, the mark treatment, the type — is the home's, unchanged.
class _Doors extends StatelessWidget {
  const _Doors(
      {required this.config,
      required this.tools,
      required this.p,
      required this.lang,
      required this.onSurface,
      required this.onAction});

  final HubConfig config;
  final List<HubTool> tools;
  final V2Palette p;
  final AppLanguage lang;
  final void Function(BuildContext, String) onSurface;
  final void Function(BuildContext, String) onAction;

  @override
  Widget build(BuildContext context) => Column(
        children: [
          for (final n in config.needs) ...[
            _Door(
                need: n,
                p: p,
                lang: lang,
                onTap: () {
                  if (n.action != null) return onAction(context, n.action!);
                  if (n.surfaceId != null) onSurface(context, n.surfaceId!);
                }),
            if (n != config.needs.last) const SizedBox(height: 10),
          ],
          // ---- tools ---------------------------------------------------
          // ⚠️ LABELLED, AND DELIBERATELY NOT DOOR-SHAPED. The note asks
          // that this "should be easily identifiable, shouldn't feel like the
          // What do you need section". A door is a pastel well with a drawn
          // mark; these are hairline rows under a heading. Different
          // vocabulary is what makes them read as a different KIND of thing
          // rather than as three more doors she has to choose between.
          if (tools.isNotEmpty) ...[
            const SizedBox(height: 26),
            Row(children: [
              Text('TOOLS',
                  style: pvManrope(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.3,
                      color: p.action.withValues(alpha: 0.85))),
              const SizedBox(width: 10),
              Expanded(child: Container(height: 1, color: p.line)),
            ]),
            const SizedBox(height: 12),
            for (final t in tools) ...[
              HubToolRow(tool: t, p: p, lang: lang, onTap: () => onSurface(context, t.surfaceId)),
              if (t != tools.last) const SizedBox(height: 9),
            ],
          ],

          // The closing offer.
          if (config.closing != null) ...[
            const SizedBox(height: 22),
            HubClosingCard(
                closing: config.closing!,
                p: p,
                lang: lang,
                onTap: () {
                  final c = config.closing!;
                  if (c.surfaceId != null) {
                    return onSurface(context, c.surfaceId!);
                  }
                  onAction(context, c.action);
                }),
          ],
        ],
      );
}

/// The closing offer — the 1:1 consult.
///
/// ⚠️ THIS USED TO BE A PLAIN HAIRLINE ROW, ON THE ARGUMENT THAT AN OFFER
/// SHOULD BE VISUALLY SUBORDINATE TO EVERY DOOR ABOVE IT. That argument was
/// principled and it was wrong in practice, and the feedback says why in one
/// sentence: "Talk to an expert should be shown differently, maybe with a
/// cover image, so that it is not ignored the way it is being ignored now,
/// looking just like a line at the bottom."
///
/// Subordinate turned out to mean invisible. A row of small text under two
/// large doors is not modest, it is skipped — and this is the one surface on
/// the hub where a mother who genuinely needs a person finds one.
///
/// ⚠️ SO IT IS A CARD, BUT STILL NOT A DOOR. It keeps a cover panel and a
/// named action, and it deliberately does NOT take the door's pastel well and
/// full-width drawn mark. Three kinds of thing on this screen — ways in,
/// things you use, a person you can book — and each has to look like its own
/// kind or the hierarchy stops meaning anything.
///
/// ⚠️ THE COVER IS DRAWN, NOT PHOTOGRAPHED. Same reasoning as the section
/// cards: a real image can drop in later without this widget changing, and a
/// tinted panel with `askDoctor` on it is a finished cover rather than a
/// placeholder for one.
///
/// ⚠️ PUBLIC for the same reason as [HubToolRow]: the four one-door brackets
/// reach their section screen without ever passing through a hub, so until now
/// they were the only brackets with no route to an expert at all.
class HubClosingCard extends StatelessWidget {
  const HubClosingCard(
      {super.key,
      required this.closing,
      required this.p,
      required this.lang,
      required this.onTap});

  final HubClosing closing;
  final V2Palette p;
  final AppLanguage lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(268, p);
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: p.surface,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: p.line),
        ),
        child: IntrinsicHeight(
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            // The cover panel.
            Container(
              width: 96,
              color: tint,
              padding: const EdgeInsets.all(19),
              child: HubIntentArt(mark: IntentMark.askDoctor, tint: tint),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(15, 15, 13, 15),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(closing.label.of(lang),
                        style: pvFraunces(
                            fontSize: 16.5,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            letterSpacing: -0.35,
                            color: p.ink1)),
                    const SizedBox(height: 5),
                    Text(closing.blurb.of(lang),
                        style: pvManrope(
                            fontSize: 12.5, height: 1.45, color: p.ink2)),
                    const SizedBox(height: 10),
                    Row(children: [
                      Text('Book a 1:1',
                          style: pvManrope(
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.3,
                              color: p.action)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward_rounded,
                          size: 14, color: p.action),
                    ]),
                  ],
                ),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}

/// A tool on the hub.
///
/// ⚠️ IT MUST NOT LOOK LIKE A DOOR AND IT MUST NOT LOOK LIKE THE CLOSING
/// OFFER, which is a narrower gap than it sounds. A door is a pastel well with
/// a drawn mark; the closing offer is a card with a cover. This is a hairline
/// row with a small square glyph well and a right chevron — the vocabulary of
/// "a thing you use", sitting under a labelled rule that names it as such.
/// One tool, drawn as a hairline row rather than as a door.
///
/// ⚠️ PUBLIC, AND SHARED WITH `PpSectionScreen`. Tools used to render only
/// here, which was correct right up until four parenting brackets turned out
/// never to reach this screen at all: a hub with ONE door opens that door's
/// destination directly, so Behaviour, Health, First 40 Days and Traditional
/// stranded seventeen tools between them with no screen to draw them on.
///
/// The fix is one widget rendered from two places, not a second tool
/// vocabulary written on the section screen. A tool has to look like a tool
/// wherever a parent meets it -- that sameness IS the affordance, and the
/// symptom that started this was a parent noticing one door "opens in a very
/// different ui than others".
class HubToolRow extends StatelessWidget {
  const HubToolRow(
      {super.key,
      required this.tool,
      required this.p,
      required this.lang,
      required this.onTap});

  final HubTool tool;
  final V2Palette p;
  final AppLanguage lang;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.fromLTRB(13, 12, 12, 13),
          decoration: BoxDecoration(
            color: p.surfaceAlt,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                color: p.surface,
                borderRadius: BorderRadius.circular(11),
                border: Border.all(color: p.line),
              ),
              child: Icon(tool.icon ?? Icons.handyman_outlined,
                  size: 17, color: p.action),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(tool.label.of(lang),
                      style: pvManrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink1)),
                  const SizedBox(height: 2),
                  Text(tool.blurb.of(lang),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 12, height: 1.4, color: p.ink3)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 19, color: p.ink3),
          ]),
        ),
      );
}

class _Door extends StatelessWidget {
  const _Door(
      {required this.need,
      required this.p,
      required this.lang,
      required this.onTap});

  final HubNeed need;
  final V2Palette p;
  final AppLanguage lang;
  final VoidCallback onTap;

  /// The home's own well gradient — the tint, lifted and dropped by 0.045.
  Color _shift(Color c, double d) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + d).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(need.hue, p);
    return Material(
      color: p.surface,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: p.line),
          ),
          child: Row(children: [
            Container(
              width: 56,
              height: 56,
              clipBehavior: Clip.antiAlias,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [_shift(tint, 0.045), _shift(tint, -0.045)],
                ),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Padding(
                padding: const EdgeInsets.all(9),
                child: HubIntentArt(mark: need.mark, tint: tint),
              ),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(need.label.of(lang),
                        style: pvFraunces(
                            fontSize: 17.5,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                            letterSpacing: -0.4,
                            color: p.ink1)),
                    const SizedBox(height: 4),
                    Text(need.blurb.of(lang),
                        style: pvManrope(
                            fontSize: 12.5, height: 1.4, color: p.ink2)),
                  ]),
            ),
            const SizedBox(width: 8),
            // ink3, not `p.action`. A violet chevron on every row makes the
            // colour mean "row" rather than "the one thing worth doing", and
            // the door is already unmistakably a door.
            Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ]),
        ),
      ),
    );
  }
}

/// The app's button. Outlined pill, transparent fill, `p.line` border.
///
/// ⚠️ LIFTED FROM `v3_daily.dart`'s journal section, which is where this was
/// settled, and re-stated here so a hub never grows its own: the app's neutrals
/// are LAVENDER-tinted, so a "grey" fill lands as a pale purple wash, and a
/// violet fill lands as a third violet on a screen that has already spent its
/// colour budget on the hue wells. **The border is what says "button".**
class HubPill extends StatelessWidget {
  const HubPill(
      {super.key,
      required this.label,
      required this.icon,
      required this.p,
      required this.onTap,
      this.fullWidth = false});

  final String label;
  final IconData icon;
  final V2Palette p;
  final VoidCallback? onTap;
  final bool fullWidth;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(999),
        child: Container(
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(999),
            border: Border.all(color: p.line, width: 1.2),
          ),
          child: Row(
              mainAxisSize: fullWidth ? MainAxisSize.max : MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon, size: 16, color: p.ink2),
                const SizedBox(width: 7),
                Flexible(
                  child: Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: pvManrope(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: p.ink2)),
                ),
              ]),
        ),
      );
}

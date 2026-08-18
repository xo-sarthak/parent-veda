// =============================================================================
//  Solution components — FINAL SPEC §7, and the symmetry rule of §6
// -----------------------------------------------------------------------------
//  ⚠️ §6 IS THE POINT OF THIS FILE, NOT §7.
//
//  "The visual identity of each solution type stays consistent across the
//  entire app. This is critical. Every Article, Video, Tool, Activity, Product,
//  Course and Consult must use the same component family everywhere. Only the
//  content, image, title, subtitle, metadata, order and quantity change."
//
//  A "component family" that lives as a paragraph in a spec becomes forty
//  slightly different cards. So it lives here as one widget with a type, and
//  every hub destination in the app builds its rows from it. A screen that
//  wants a differently-shaped article card has to change this file, which is a
//  review, rather than write its own, which is a Tuesday.
//
//  ---------------------------------------------------------------------------
//  THE TYPE LABEL IS THE FAMILY'S SIGNATURE
//  ---------------------------------------------------------------------------
//  `READ · 4 MIN` · `WATCH · 5 MIN` · `CALCULATOR` · `CONSULT`
//
//  It is what lets her learn the app once: the same small caps chip means the
//  same kind of thing on the Scans hub, the Sleep hub and the PCOS hub. It is
//  also the one piece of inventory language that IS allowed to reach her —
//  because "READ" describes what she will DO, whereas "Content" described how
//  we filed it.
//
//  ---------------------------------------------------------------------------
//  ⚠️ VIDEO GETS THE SAME SHELL WHETHER OR NOT MEDIA EXISTS — §7.2
//  ---------------------------------------------------------------------------
//  "The video shell should exist even when media is not yet published. A
//  notReady video uses the same shell with COMING SOON."
//
//  That is a build-order instruction and it is the cheapest thing in this whole
//  plan to get right: the row, the thumbnail, the duration and the position are
//  laid out now, so publishing a film is a data change and never a layout job
//  across forty screens.
//
//  ---------------------------------------------------------------------------
//  ⚠️ NO FILLED VIOLET ANYWHERE
//  ---------------------------------------------------------------------------
//  Cards are `p.surface` with a `p.line` border, exactly like the V3 home's.
//  Chevrons are `ink3`. The only colour is the type well, in the hue the caller
//  gives it — the same gradient-well treatment the home's doors use.
// =============================================================================

import 'package:flutter/material.dart';

import '../../../localization/app_language.dart';
import '../../../theme/pv_fonts.dart';
import '../../v2/v2_palette.dart';

/// The seven solution types of §7. The type decides the chip and the default
/// hue, so a caller cannot accidentally give articles and videos two different
/// looks on two different hubs.
enum SolutionType { read, watch, tool, activity, product, course, consult }

extension SolutionMeta on SolutionType {
  /// The small-caps chip. `null` metadata means the chip is just the type.
  String chip(AppLanguage lang) => switch (this) {
        SolutionType.read => lang.isEnglish ? 'READ' : 'पढ़ें',
        SolutionType.watch => lang.isEnglish ? 'WATCH' : 'देखें',
        SolutionType.tool => lang.isEnglish ? 'TOOL' : 'TOOL',
        SolutionType.activity => lang.isEnglish ? 'DO' : 'करें',
        SolutionType.product => lang.isEnglish ? 'THING' : 'सामान',
        SolutionType.course => lang.isEnglish ? 'PROGRAMME' : 'programme',
        SolutionType.consult => lang.isEnglish ? 'TALK' : 'बात करें',
      };

  IconData get icon => switch (this) {
        SolutionType.read => Icons.menu_book_outlined,
        SolutionType.watch => Icons.play_arrow_rounded,
        SolutionType.tool => Icons.tune_rounded,
        SolutionType.activity => Icons.self_improvement_rounded,
        SolutionType.product => Icons.shopping_bag_outlined,
        SolutionType.course => Icons.school_outlined,
        SolutionType.consult => Icons.chat_bubble_outline_rounded,
      };

  /// ⚠️ ONE HUE PER SOLUTION TYPE, ACROSS THE WHOLE APP. This is what makes
  /// §6's symmetry visible rather than merely structural: every READ is the
  /// same blue on every hub, so she learns the colour once.
  double get hue => switch (this) {
        SolutionType.read => 206,
        SolutionType.watch => 344,
        SolutionType.tool => 160,
        SolutionType.activity => 42,
        SolutionType.product => 12,
        SolutionType.course => 268,
        SolutionType.consult => 186,
      };
}

/// One solution, as a card. The whole family.
class SolutionCard extends StatelessWidget {
  const SolutionCard({
    super.key,
    required this.type,
    required this.title,
    required this.value,
    required this.p,
    required this.lang,
    this.meta,
    this.onTap,
    this.comingSoon = false,
  });

  final SolutionType type;

  /// What it is, in her words.
  final LocalizedText title;

  /// ⚠️ ONE LINE ON WHY IT IS WORTH HER TIME — required by every §7 entry
  /// ("one-line value", "one-line reason to watch", "one-line outcome"). A card
  /// with a title and no reason is a link, and a list of links is the catalogue
  /// this restructure replaced.
  final LocalizedText value;

  /// "4 MIN", "CALCULATOR". Appended to the type chip.
  final LocalizedText? meta;

  final V2Palette p;
  final AppLanguage lang;
  final VoidCallback? onTap;

  /// §7.2 / §12 — the same shell, not a different component.
  final bool comingSoon;

  Color _shift(Color c, double d) {
    final h = HSLColor.fromColor(c);
    return h.withLightness((h.lightness + d).clamp(0.0, 1.0)).toColor();
  }

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(type.hue, p);
    final ink = HSLColor.fromColor(tint)
        .withSaturation(0.46)
        .withLightness(0.40)
        .toColor();

    final chip = meta == null
        ? type.chip(lang)
        : '${type.chip(lang)} · ${meta!.of(lang)}';

    final card = Container(
      padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
      decoration: BoxDecoration(
        // A coming-soon card is the SAME card a shade back — never dashed,
        // never grey-blocked. Broken-looking placeholders make a screen read as
        // abandoned; this one reads as "not yet", which is the truth.
        color: comingSoon ? p.surfaceAlt : p.surface,
        borderRadius: BorderRadius.circular(18),
        border: comingSoon ? null : Border.all(color: p.line),
      ),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 52,
          height: 52,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [_shift(tint, 0.045), _shift(tint, -0.045)],
            ),
            borderRadius: BorderRadius.circular(14),
          ),
          child: Icon(type.icon, size: 22, color: ink),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title.of(lang),
                    style: pvFraunces(
                        fontSize: 16.5,
                        fontWeight: FontWeight.w600,
                        height: 1.22,
                        letterSpacing: -0.35,
                        color: comingSoon ? p.ink2 : p.ink1)),
                const SizedBox(height: 4),
                Text(value.of(lang),
                    style: pvManrope(
                        fontSize: 12.5,
                        height: 1.4,
                        color: comingSoon ? p.ink3 : p.ink2)),
                const SizedBox(height: 8),
                Text(
                    comingSoon
                        ? '$chip · ${lang.isEnglish ? 'COMING SOON' : 'जल्द'}'
                        : chip,
                    style: pvManrope(
                        fontSize: 9.5,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.1,
                        color: comingSoon ? p.ink3 : ink)),
              ]),
        ),
        if (!comingSoon) ...[
          const SizedBox(width: 6),
          Padding(
            padding: const EdgeInsets.only(top: 14),
            child:
                Icon(Icons.chevron_right_rounded, size: 20, color: p.ink3),
          ),
        ],
      ]),
    );

    // ⚠️ A COMING-SOON CARD IS NOT TAPPABLE. A tappable placeholder opens a
    // sheet that says "coming soon" again — a dead end wearing a gesture — and
    // it teaches her that rows in this app may do nothing, which spreads doubt
    // to the rows that work.
    if (comingSoon || onTap == null) return card;
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(18),
          child: card),
    );
  }
}

/// A group of solution cards under one heading, in her language.
///
/// ⚠️ THE HEADING IS NEVER A SOLUTION TYPE. §2.1 and §8 — "Articles" is a
/// heading we would write; "Before you go" is what she is actually doing.
class SolutionGroup extends StatelessWidget {
  const SolutionGroup(
      {super.key,
      required this.title,
      required this.cards,
      required this.p,
      required this.lang});

  final LocalizedText title;
  final List<Widget> cards;
  final V2Palette p;
  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    if (cards.isEmpty) return const SizedBox.shrink();
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Text(title.of(lang),
          style: pvFraunces(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              height: 1.2,
              letterSpacing: -0.45,
              color: p.ink1)),
      const SizedBox(height: 12),
      for (final c in cards) ...[
        c,
        if (c != cards.last) const SizedBox(height: 10),
      ],
    ]);
  }
}

// =============================================================================
//  Explore kit — the one layout four screens share.
// -----------------------------------------------------------------------------
//  Four separate redesign briefs (Recipes, Recommendations, Read, Courses) all
//  describe the SAME page, and say so out loud: "reuse as much of the
//  architecture built for the Recipes screen", "should feel like its sibling",
//  "so all three sections feel like part of one cohesive Explore experience".
//
//  The pattern, in every one of them:
//
//      expert banner  ->  search  ->  filters/chips  ->  a personalised
//      "chosen for you"  ->  horizontal category sections with See more  ->
//      dedicated listing pages
//
//  So it is built once, here, and applied four times. Four screens that merely
//  LOOK alike drift within a month; four screens built from the same widgets
//  cannot.
//
// -----------------------------------------------------------------------------
//  WHAT THE BRIEFS ASKED FOR THAT THIS DELIBERATELY DOES NOT USE
//
//  All four specify Riverpod, GoRouter, Theme Extensions and
//  CachedNetworkImage. This repo is singleton ChangeNotifier stores and
//  imperative Navigator, by a decision recorded in CLAUDE.md and re-taken more
//  than once: adopting a second state paradigm for one feature means two ways
//  to do everything and shared services that fit neither. The route NAME is
//  also load-bearing here (global_ask_fab reads it), which GoRouter would
//  break.
//
//  So the LAYOUT and the BEHAVIOUR of all four briefs are built exactly as
//  described; the plumbing is this codebase's. cached_network_image is not a
//  dependency and none of this content is network imagery yet, so images use
//  the existing placeholder treatments.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';

// =============================================================================
//  1. EXPERT CURATED BANNER
// -----------------------------------------------------------------------------
//  Every brief opens with this, and every one of them gives the same reason:
//  "increase trust immediately". It is the first thing under the title and it
//  says why anything below it is worth reading.
//
//  Deliberately compact. A trust banner that takes a third of the first screen
//  stops being reassurance and becomes an obstacle between a parent and the
//  thing they opened the page for.
// =============================================================================

class ExpertCuratedBanner extends StatelessWidget {
  const ExpertCuratedBanner({
    super.key,
    required this.text,
    this.icon = Icons.verified_user_outlined,
    this.accent = const Color(0xFF3E7A5E),
  });

  final String text;
  final IconData icon;
  final Color accent;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
        decoration: BoxDecoration(
          color: ppPanel,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(9),
            ),
            child: Icon(icon, size: 15, color: accent),
          ),
          const SizedBox(width: 11),
          Expanded(
            child: Text(text, style: ppBody(12.5, h: 1.5, color: ppInk)),
          ),
        ]),
      );
}

// =============================================================================
//  2. SEARCH BAR
// -----------------------------------------------------------------------------
//  Instant, with a clear button once there is something to clear. Every brief
//  asks for the same three things and they are the three that matter.
// =============================================================================

class ExploreSearchBar extends StatelessWidget {
  const ExploreSearchBar({
    super.key,
    required this.controller,
    required this.hint,
    required this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 3),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: ppBorder),
        ),
        child: Row(children: [
          const Icon(Icons.search_rounded, size: 20, color: ppMuted),
          const SizedBox(width: 10),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: ppBody(14.5, color: ppInk),
              cursorColor: ppPurple,
              decoration: InputDecoration(
                isDense: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: ppBody(14, color: ppMuted),
              ),
            ),
          ),
          if (controller.text.isNotEmpty)
            GestureDetector(
              onTap: () {
                controller.clear();
                onChanged('');
                FocusScope.of(context).unfocus();
              },
              behavior: HitTestBehavior.opaque,
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(Icons.close_rounded, size: 18, color: ppMuted),
              ),
            ),
        ]),
      );
}

// =============================================================================
//  3. CHIPS
// -----------------------------------------------------------------------------
//  TWO KINDS, and the briefs are careful to distinguish them:
//
//    FILTER chips    change what is shown (Recipes' All/Veg/Vegan/Non-veg,
//                    Read's topic and type rows). Selected = purple fill.
//
//    NAVIGATION chips jump to a section further down the same page. The
//                    Recommendations brief is explicit: "These are NOT
//                    filters. These are section navigation shortcuts."
//
//  They look almost identical and behave completely differently, so they are
//  separate widgets rather than one with a flag. A parent tapping "Toys"
//  expecting the page to filter, and getting a scroll instead, is a small
//  betrayal that a shared widget makes easy to ship.
// =============================================================================

class ExploreFilterChips extends StatelessWidget {
  const ExploreFilterChips({
    super.key,
    required this.labels,
    required this.selected,
    required this.onSelect,
    this.icons = const [],
  });

  final List<String> labels;
  final String selected;
  final ValueChanged<String> onSelect;

  /// Optional, one per label. The Recipes brief shows leaf glyphs on the diet
  /// chips; line icons here, per the app-wide no-decorative-emoji rule.
  final List<IconData> icons;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: 38,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          itemCount: labels.length,
          separatorBuilder: (_, _) => const SizedBox(width: 9),
          itemBuilder: (_, i) {
            final on = labels[i] == selected;
            return GestureDetector(
              onTap: () => onSelect(labels[i]),
              behavior: HitTestBehavior.opaque,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                padding: const EdgeInsets.symmetric(horizontal: 15),
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: on ? ppPurple : Colors.white,
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(color: on ? ppPurple : ppBorder),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  if (i < icons.length) ...[
                    Icon(icons[i],
                        size: 14, color: on ? Colors.white : ppSoft),
                    const SizedBox(width: 6),
                  ],
                  Text(labels[i],
                      style: ppBody(12.5,
                          color: on ? Colors.white : ppInk,
                          w: FontWeight.w700)),
                ]),
              ),
            );
          },
        ),
      );
}

/// One destination for the navigation chips.
class ExploreNavTarget {
  ExploreNavTarget({required this.label, required this.icon})
      : key = GlobalKey();

  final String label;
  final IconData icon;

  /// Attached to the section's header so the chip can find it on screen.
  ///
  /// A GlobalKey rather than a measured offset table: offsets go stale the
  /// moment a section above changes height — which happens here every time a
  /// filter is applied — and a chip that scrolls to where a section USED to be
  /// is worse than one that does nothing.
  final GlobalKey key;
}

/// Section-jumping chips. Sticky, per the brief, via a SliverPersistentHeader
/// in the host screen; this widget is just the row.
class ExploreNavChips extends StatelessWidget {
  const ExploreNavChips({
    super.key,
    required this.targets,
    required this.activeIndex,
    required this.onTap,
  });

  final List<ExploreNavTarget> targets;
  final int activeIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) => Container(
        height: 74,
        color: ppBg,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.fromLTRB(22, 6, 22, 6),
          itemCount: targets.length,
          separatorBuilder: (_, _) => const SizedBox(width: 16),
          itemBuilder: (_, i) {
            final on = i == activeIndex;
            return GestureDetector(
              onTap: () => onTap(i),
              behavior: HitTestBehavior.opaque,
              child: SizedBox(
                width: 62,
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 160),
                    width: 42,
                    height: 42,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: on
                          ? ppPurple.withValues(alpha: 0.12)
                          : Colors.white,
                      borderRadius: BorderRadius.circular(14),
                      border:
                          Border.all(color: on ? ppPurple : ppBorder),
                    ),
                    child: Icon(targets[i].icon,
                        size: 20, color: on ? ppPurple : ppSoft),
                  ),
                  const SizedBox(height: 5),
                  Text(targets[i].label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                      style: ppBody(10.5,
                          color: on ? ppPurple : ppSoft,
                          w: on ? FontWeight.w800 : FontWeight.w600)),
                ]),
              ),
            );
          },
        ),
      );
}

// =============================================================================
//  4. SECTION HEADER + HORIZONTAL RAIL
// -----------------------------------------------------------------------------
//  "Section Name … See more →", then a horizontal rail. Every brief describes
//  this and every one of them says "exactly like Netflix sections".
//
//  The rail takes already-built cards rather than building them, because the
//  four screens genuinely differ there: a recipe card is an image with an age
//  tag, a course card carries an expert and a price. The FRAME is shared; the
//  card is each screen's own.
// =============================================================================

class ExploreSectionHeader extends StatelessWidget {
  const ExploreSectionHeader({
    super.key,
    required this.title,
    this.onSeeMore,
    this.seeMoreLabel = 'See more',
    this.anchorKey,
    this.subtitle,
  });

  final String title;
  final VoidCallback? onSeeMore;
  final String seeMoreLabel;

  /// The nav chips scroll to this.
  final GlobalKey? anchorKey;
  final String? subtitle;

  @override
  Widget build(BuildContext context) => Padding(
        key: anchorKey,
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Expanded(child: Text(title, style: ppJakarta(17))),
            if (onSeeMore != null)
              GestureDetector(
                onTap: onSeeMore,
                behavior: HitTestBehavior.opaque,
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  Text(seeMoreLabel,
                      style:
                          ppBody(12.5, color: ppPurple, w: FontWeight.w700)),
                  const SizedBox(width: 3),
                  const Icon(Icons.chevron_right_rounded,
                      size: 18, color: ppPurple),
                ]),
              ),
          ]),
          if (subtitle != null) ...[
            const SizedBox(height: 3),
            Text(subtitle!, style: ppBody(12, color: ppMuted)),
          ],
        ]),
      );
}

class ExploreRail extends StatelessWidget {
  const ExploreRail({
    super.key,
    required this.height,
    required this.children,
    this.itemWidth = 152,
  });

  final double height;
  final List<Widget> children;
  final double itemWidth;

  @override
  Widget build(BuildContext context) => SizedBox(
        height: height,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 22),
          itemCount: children.length,
          separatorBuilder: (_, _) => const SizedBox(width: 12),
          itemBuilder: (_, i) =>
              SizedBox(width: itemWidth, child: children[i]),
        ),
      );
}

// =============================================================================
//  5. EMPTY STATE
// -----------------------------------------------------------------------------
//  Every brief asks for one, and the house rule already required it: a feature
//  is never hidden, and the empty state is the feature's advertisement. So it
//  always says what to do next rather than only that there is nothing here.
// =============================================================================

class ExploreEmpty extends StatelessWidget {
  const ExploreEmpty({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon = Icons.search_off_rounded,
    this.cta,
    this.onCta,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final String? cta;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(24),
          decoration: BoxDecoration(
            color: ppPanel,
            borderRadius: BorderRadius.circular(18),
          ),
          child: Column(children: [
            Icon(icon, size: 30, color: ppMuted),
            const SizedBox(height: 12),
            Text(title, textAlign: TextAlign.center, style: ppJakarta(15)),
            const SizedBox(height: 6),
            Text(subtitle,
                textAlign: TextAlign.center,
                style: ppBody(12.5, h: 1.5)),
            if (cta != null) ...[
              const SizedBox(height: 16),
              GestureDetector(
                onTap: onCta,
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: ppPurple,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(cta!,
                      style: ppBody(13,
                          color: Colors.white, w: FontWeight.w800)),
                ),
              ),
            ],
          ]),
        ),
      );
}

// =============================================================================
//  6. CARD PARTS
// =============================================================================

/// A small overlay badge — the age tag on a recipe, "Expert Pick" on a
/// recommendation.
class ExploreBadge extends StatelessWidget {
  const ExploreBadge({
    super.key,
    required this.label,
    this.color = Colors.white,
    this.ink = ppInk,
  });

  final String label;
  final Color color;
  final Color ink;

  @override
  Widget build(BuildContext context) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(label,
            style: ppBody(10, color: ink, w: FontWeight.w800)),
      );
}

/// The bookmark on a card. Stateless — the host passes `saved` and a toggle,
/// so the one source of truth stays in whichever store already owns it.
class ExploreBookmark extends StatelessWidget {
  const ExploreBookmark({
    super.key,
    required this.saved,
    required this.onTap,
  });

  final bool saved;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          width: 28,
          height: 28,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Colors.white,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(color: Color(0x14000000), blurRadius: 6, offset: Offset(0, 2)),
            ],
          ),
          child: Icon(
              saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
              size: 15,
              color: ppPurple),
        ),
      );
}

/// The image block on a card.
///
/// There is no photography in the app for most of this content and
/// cached_network_image is not a dependency, so this draws a calm tinted panel
/// with the category's icon. Honest, and it keeps the layout the briefs asked
/// for — image-first — so dropping real photos in later changes one widget.
class ExploreThumb extends StatelessWidget {
  const ExploreThumb({
    super.key,
    required this.icon,
    required this.accent,
    this.height = 104,
    this.radius = 14,
    this.topLeft,
    this.topRight,
    this.centre,
  });

  final IconData icon;
  final Color accent;
  final double height;
  final double radius;
  final Widget? topLeft;
  final Widget? topRight;

  /// e.g. a play button for a card whose item has a video.
  final Widget? centre;

  @override
  Widget build(BuildContext context) => ClipRRect(
        borderRadius: BorderRadius.circular(radius),
        child: Container(
          height: height,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                accent.withValues(alpha: 0.16),
                accent.withValues(alpha: 0.06),
              ],
            ),
          ),
          child: Stack(children: [
            Center(child: Icon(icon, size: 30, color: accent)),
            if (centre != null) Center(child: centre!),
            if (topLeft != null)
              Positioned(top: 7, left: 7, child: topLeft!),
            if (topRight != null)
              Positioned(top: 7, right: 7, child: topRight!),
          ]),
        ),
      );
}

// =============================================================================
//  7. THE SCROLL-SPY
// -----------------------------------------------------------------------------
//  "clicking chip scrolls smoothly to corresponding section" and "active chip
//  automatically changes while user scrolls".
//
//  Both directions from one place, because doing them separately is how they
//  end up disagreeing: tapping a chip scrolls, which fires the listener, which
//  re-picks the active chip from geometry — so the tap and the scroll can
//  briefly fight. `_jumping` suppresses the spy for the duration of an
//  animated jump, which is the whole reason it exists.
// =============================================================================

class ExploreScrollSpy {
  ExploreScrollSpy({required this.controller, required this.targets});

  final ScrollController controller;
  final List<ExploreNavTarget> targets;

  bool _jumping = false;

  /// Which section is nearest the top of the viewport right now.
  ///
  /// Reads real geometry rather than a table of offsets: a filter change
  /// re-flows every section above, and a stale offset table would scroll to
  /// where a section used to be.
  int activeIndex() {
    var best = 0;
    var bestDy = double.infinity;
    for (var i = 0; i < targets.length; i++) {
      final ctx = targets[i].key.currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) continue;
      final dy = box.localToGlobal(Offset.zero).dy;
      // A section counts as "current" once its header is at or just above the
      // top of the list. 140 is the sticky header's own height plus a little,
      // so the chip flips as the section slides under the chips rather than
      // when it has already gone.
      if (dy <= 140 && (140 - dy) < bestDy) {
        bestDy = 140 - dy;
        best = i;
      }
    }
    return best;
  }

  bool get isJumping => _jumping;

  Future<void> jumpTo(int i) async {
    final ctx = targets[i].key.currentContext;
    if (ctx == null) return;
    _jumping = true;
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 420),
      curve: Curves.easeInOutCubic,
      alignment: 0.0,
    );
    _jumping = false;
  }
}

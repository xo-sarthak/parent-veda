// =============================================================================
//  TTC — the More tab
// -----------------------------------------------------------------------------
//  ⚠️ RETIRED 2026-09-26, KEPT FOR REVERT. The V3 bar is Today · Learn ·
//  Products · Tools · You; nothing pushes this screen any more. Its rows moved
//  to the TTC `things` in `lib/screens/profile/pv_you_content.dart` (Calendar,
//  Cycle companion, Fertility window, All programmes and sessions; Journal and
//  Profile were already on You). Community is held back. The reasoning below
//  is the 2026-09-17 version and still explains why every row needs a home.
// -----------------------------------------------------------------------------
//  ⚠️ THIS SCREEN EXISTS BECAUSE THE V3 NAV DROPPED TWO TABS AND NARROWED A
//  THIRD. It is not a junk drawer, it is the other half of a deliberate trade,
//  and the trade only holds if this screen is complete.
//
//  V1's nav is Today · Prepare · Tools · Calendar · Community.
//  V3's nav is  Today · Courses · Tools · Talk to expert · More.
//
//  Three things changed and each one costs something:
//
//    · **Calendar and Community lost their tabs.** They are the two screens a
//      woman visits least often and reaches for deliberately when she does, so
//      they trade a permanent slot for one tap. Both are here.
//    · **Prepare was split.** Two of its nine categories — courses and
//      consultations — got tabs of their own because they are the two the stage
//      is actually built to sell. The other SEVEN had no entrance at all for
//      about an hour, which is the wiring-gate failure CLAUDE.md names, caught
//      by asking "where did yoga go?" rather than by any test. All nine are
//      reachable from here through the unfiltered Prepare screen.
//    · **The Today tab absorbed the cycle.** The V3 header is the cycle spine
//      now, but the cycle COMPANION — the deeper screen behind it — was only
//      ever reachable from a card. It is here too.
//
//  ⚠️ IF YOU ADD A TAB TO V3'S NAV, RE-READ THIS FILE. A tab that promotes
//  something out of this list leaves a row here pointing at a screen the nav
//  already shows, which is harmless; a tab that REPLACES one leaves whatever it
//  displaced with no entrance anywhere. That direction is the one that breaks.
// =============================================================================

import 'package:flutter/material.dart';

import '../../theme/pv_fonts.dart';
import '../v2/v2_palette.dart';
import 'ttc_common.dart';
import 'ttc_prepare_screen.dart';
import 'ttc_profile_screen.dart';
import 'ttc_strings.dart';
import 'ttc_surface_router.dart';

class TtcMoreScreen extends StatelessWidget {
  const TtcMoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: Listenable.merge([TtcLang.instance, V2PaletteStore.instance]),
      builder: (context, _) {
        final t = TtcS.current();
        final p = V2PaletteStore.instance.current;

        return Scaffold(
          backgroundColor: ttcBg,
          body: SafeArea(
            child: Stack(children: [
              ListView(
                padding: const EdgeInsets.fromLTRB(
                    ttcGutter, 8, ttcGutter, ttcBottomInset),
                children: [
                  TtcBackBar(title: t.moreTitle),
                  const SizedBox(height: 8),
                  Text(t.moreIntro,
                      style: ttcBody(13.5, color: ttcMuted, h: 1.55)),
                  const SizedBox(height: 20),

                  // ---- the cycle ------------------------------------------
                  ttcSectionTitle(t.moreYourCycle),
                  _MoreCard(p: p, rows: [
                    _MoreRow(
                      icon: Icons.calendar_month_rounded,
                      hue: 268,
                      label: t.tabCalendar,
                      p: p,
                      onTap: () => openTtcSurface(context, 'ttc_calendar'),
                    ),
                    _MoreRow(
                      icon: Icons.timeline_rounded,
                      hue: 206,
                      label: t.cycleCompanion,
                      p: p,
                      onTap: () => openTtcSurface(context, 'ttc_cycle'),
                    ),
                    _MoreRow(
                      icon: Icons.wb_twilight_rounded,
                      hue: 160,
                      label: t.fertilityWindow,
                      p: p,
                      last: true,
                      onTap: () => openTtcSurface(context, 'ttc_window'),
                    ),
                  ]),
                  const SizedBox(height: 22),

                  // ---- people ---------------------------------------------
                  ttcSectionTitle(t.tabCommunity),
                  _MoreCard(p: p, rows: [
                    _MoreRow(
                      icon: Icons.groups_rounded,
                      hue: 42,
                      label: t.tabCommunity,
                      p: p,
                      onTap: () => openTtcSurface(context, 'ttc_community'),
                    ),
                    // Kept for revert (2026-09-28, journal out of TTC):
                    // _MoreRow(
                    //   icon: Icons.favorite_border_rounded,
                    //   hue: 344,
                    //   label: t.myJournal,
                    //   p: p,
                    //   onTap: () => openTtcSurface(context, 'ttc_journal'),
                    // ),
                    _MoreRow(
                      icon: Icons.person_outline_rounded,
                      hue: 104,
                      label: t.profileTitle,
                      p: p,
                      last: true,
                      onTap: () => openTtcProfile(context),
                    ),
                  ]),
                  const SizedBox(height: 22),

                  // ---- the seven categories without a tab ------------------
                  //
                  // ⚠️ THE WHOLE OF PREPARE, UNFILTERED. Courses and consults
                  // have tabs; the other seven categories are only reachable
                  // through this one row. Scoping it — showing, say, only yoga
                  // — is how the remaining six would quietly disappear.
                  ttcSectionTitle(t.tabPrepare),
                  InkWell(
                    onTap: () =>
                        Navigator.of(context).push(MaterialPageRoute<void>(
                      settings: const RouteSettings(name: 'ttc/prepare'),
                      builder: (_) => const TtcPrepareScreen(),
                    )),
                    borderRadius: BorderRadius.circular(ttcCardRadius),
                    child: TtcCard(
                      child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 38,
                              height: 38,
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: v2BlockTint(186, p),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(Icons.auto_awesome_outlined,
                                  size: 19, color: ttcTitleInk),
                            ),
                            const SizedBox(width: 13),
                            Expanded(
                              child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(t.moreEverythingPaid,
                                        style: ttcFraunces(16,
                                            w: FontWeight.w600,
                                            color: ttcTitleInk)),
                                    const SizedBox(height: 5),
                                    Text(t.moreEverythingPaidBody,
                                        style: ttcBody(12.5,
                                            color: ttcMuted, h: 1.5)),
                                  ]),
                            ),
                          ]),
                    ),
                  ),
                ],
              ),
              Positioned(
                left: 14,
                right: 14,
                bottom: 14,
                child: SafeArea(
                    top: false, child: TtcBottomNav(active: 4, v3: true)),
              ),
            ]),
          ),
        );
      },
    );
  }
}

class _MoreCard extends StatelessWidget {
  const _MoreCard({required this.p, required this.rows});

  final V2Palette p;
  final List<Widget> rows;

  @override
  Widget build(BuildContext context) => Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(ttcCardRadius),
          border: Border.all(color: ttcLine),
        ),
        child: Column(children: rows),
      );
}

class _MoreRow extends StatelessWidget {
  const _MoreRow({
    required this.icon,
    required this.hue,
    required this.label,
    required this.p,
    required this.onTap,
    this.last = false,
  });

  final IconData icon;
  final double hue;
  final String label;
  final V2Palette p;
  final VoidCallback onTap;
  final bool last;

  @override
  Widget build(BuildContext context) {
    final tint = v2BlockTint(hue, p);
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
        decoration: BoxDecoration(
          border: last ? null : const Border(bottom: BorderSide(color: ttcLine)),
        ),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: tint, borderRadius: BorderRadius.circular(11)),
            child: Icon(icon,
                size: 18,
                color: HSLColor.fromColor(tint)
                    .withSaturation(0.46)
                    .withLightness(0.42)
                    .toColor()),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(label,
                style: pvManrope(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: ttcTitleInk)),
          ),
          Icon(Icons.chevron_right_rounded, size: 20, color: ttcMuted),
        ]),
      ),
    );
  }
}

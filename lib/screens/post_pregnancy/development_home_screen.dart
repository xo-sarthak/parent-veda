// =============================================================================
//  DevelopmentHomeScreen - ParentVeda Development (a development COMPANION)
// -----------------------------------------------------------------------------
//  Answers "how can I help my child grow and learn at this stage?" - one Today's
//  Focus, the birth-to-five Development Map, the eight development areas (each its
//  own journey), today's activities, a Brain Development window, Looking Ahead,
//  and a gentle check-in. Inspires action, never evaluates. Playful and warm,
//  deliberately distinct from Health's calm structure. Reached from Explore.
// =============================================================================

import 'package:flutter/material.dart';

import 'development_activity_screen.dart';
import 'development_area_screen.dart';
import 'development_checkin_screen.dart';
import 'development_common.dart';
import 'development_map_screen.dart';
import 'pp_common.dart';
import 'pp_development_data.dart';

class DevelopmentHomeScreen extends StatelessWidget {
  const DevelopmentHomeScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    final focus = todaysFocus();
    final activities = kDevActivities.take(4).toList();
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Explore')),
            const SizedBox(height: 18),
            _pad(ppEyebrow('ParentVeda Development', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text('Help Aarav grow', style: ppFraunces(30, h: 1.1))),
            const SizedBox(height: 6),
            _pad(Text('Not a checklist of what he’s done - what he’s learning now, and how you can nurture it today.', style: ppBody(14, h: 1.5))),

            // 1 - today's focus
            const SizedBox(height: 24),
            _pad(_focusHero(context, focus)),

            // development map (signature)
            const SizedBox(height: 24),
            _pad(_mapCta(context)),

            // 2 - development areas
            const SizedBox(height: 30),
            _pad(devSectionHeader('Every part of him, growing')),
            const SizedBox(height: 4),
            _pad(Text('Eight areas, each its own little journey - tap to explore.', style: ppBody(12.5, color: ppMuted))),
            const SizedBox(height: 16),
            SizedBox(
              height: 208,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: kDevAreas.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (_, i) => DevAreaCard(area: kDevAreas[i], width: 210, onTap: () => _push(context, DevelopmentAreaScreen(area: kDevAreas[i]))),
              ),
            ),

            // 4 - today's activities
            const SizedBox(height: 30),
            _pad(devSectionHeader("Try together today")),
            const SizedBox(height: 4),
            _pad(Text('Small, joyful things that support exactly where he is.', style: ppBody(12.5, color: ppMuted))),
            const SizedBox(height: 16),
            _pad(Column(children: [for (final a in activities) DevActivityCard(activity: a, onTap: () => _push(context, DevelopmentActivityScreen(activity: a)))])),

            // 5 - brain development
            const SizedBox(height: 14),
            _pad(_brain(context)),

            // 6 - looking ahead
            const SizedBox(height: 30),
            _pad(devSectionHeader('Looking ahead')),
            const SizedBox(height: 4),
            _pad(Text('Something to look forward to - no rigid timelines, just the joy of what’s coming.', style: ppBody(12.5, color: ppMuted))),
            const SizedBox(height: 16),
            SizedBox(
              height: 150,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: kLookAhead.length,
                separatorBuilder: (_, _) => const SizedBox(width: 14),
                itemBuilder: (_, i) => _aheadCard(kLookAhead[i]),
              ),
            ),

            // check-in
            const SizedBox(height: 26),
            _pad(_checkinCta(context)),
          ],
        ),
      ),
    );
  }

  // ---- today's focus hero -------------------------------------------------
  Widget _focusHero(BuildContext context, DevArea a) => Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [a.accent.withValues(alpha: 0.14), a.accent.withValues(alpha: 0.04)]),
          borderRadius: BorderRadius.circular(24),
          border: Border.all(color: a.accent.withValues(alpha: 0.2)),
        ),
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            Container(width: 6, height: 6, decoration: BoxDecoration(color: a.accent, shape: BoxShape.circle)),
            const SizedBox(width: 7),
            Flexible(child: ppEyebrow("Today’s focus · ${a.name}", color: a.accent, spacing: 0.8)),
          ]),
          const SizedBox(height: 14),
          Text(a.stage, style: ppFraunces(24, h: 1.15)),
          const SizedBox(height: 8),
          Text(a.summary, style: ppBody(14, h: 1.55)),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(14)),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Icon(Icons.wb_sunny_outlined, size: 16, color: a.accent),
              const SizedBox(width: 10),
              Expanded(child: Text.rich(TextSpan(children: [
                TextSpan(text: 'One thing today: ', style: TextStyle(fontWeight: FontWeight.w800, color: ppInk)),
                TextSpan(text: a.todayTip, style: const TextStyle(color: ppInk)),
              ]), style: ppBody(12.5, h: 1.5))),
            ]),
          ),
          const SizedBox(height: 16),
          Row(children: [
            Flexible(
              child: GestureDetector(
                onTap: () => _push(context, DevelopmentActivityScreen(activity: devActivityById(a.nextActivityId ?? 'narrate'))),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11),
                  decoration: BoxDecoration(color: a.accent, borderRadius: BorderRadius.circular(999)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    Flexible(child: Text('Explore today’s activity', style: ppBody(13, color: Colors.white, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                    const SizedBox(width: 7),
                    const Icon(Icons.arrow_forward, size: 15, color: Colors.white),
                  ]),
                ),
              ),
            ),
          ]),
        ]),
      );

  // ---- development map cta ------------------------------------------------
  Widget _mapCta(BuildContext context) => GestureDetector(
        onTap: () => _push(context, const DevelopmentMapScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(color: ppInk, borderRadius: BorderRadius.circular(22)),
          child: Row(children: [
            Container(width: 46, height: 46, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(14)), child: const Icon(Icons.map_outlined, size: 22, color: Colors.white)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('The Development Map', style: ppJakarta(15.5, color: Colors.white)),
                const SizedBox(height: 3),
                Text('Birth to five, as one beautiful journey. See where he is - and the wonder ahead.', style: ppBody(12.5, color: Colors.white.withValues(alpha: 0.8), h: 1.4)),
              ]),
            ),
            const SizedBox(width: 10),
            Icon(Icons.chevron_right_rounded, size: 20, color: Colors.white.withValues(alpha: 0.8)),
          ]),
        ),
      );

  // ---- brain development --------------------------------------------------
  Widget _brain(BuildContext context) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: const LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [Color(0xFFF1EAF8), Color(0xFFEFE9FB)]),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            const Icon(Icons.psychology_outlined, size: 17, color: ppPurple),
            const SizedBox(width: 8),
            ppEyebrow('Inside his brain this month', color: ppPurple, spacing: 0.8),
          ]),
          const SizedBox(height: 12),
          Text(kBrainThisWeek, style: ppBody(13.5, color: ppInk, h: 1.6)),
          const SizedBox(height: 14),
          GestureDetector(
            onTap: () => _brainSheet(context),
            behavior: HitTestBehavior.opaque,
            child: Row(children: [
              Flexible(child: Text('How his brain is growing', style: ppBody(13, color: ppPurple, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
              const SizedBox(width: 6),
              const Icon(Icons.arrow_forward, size: 14, color: ppPurple),
            ]),
          ),
        ]),
      );

  void _brainSheet(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: ppBg,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(26))),
      builder: (ctx) => SafeArea(
        top: false,
        child: ConstrainedBox(
          constraints: BoxConstraints(maxHeight: MediaQuery.of(ctx).size.height * 0.85),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 30),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 38, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(999)))),
              const SizedBox(height: 16),
              Text('How his brain is growing', style: ppFraunces(24, h: 1.12)),
              const SizedBox(height: 6),
              Text('Simple windows into a remarkable month - each with one practical thing you can do.', style: ppBody(13, h: 1.5)),
              const SizedBox(height: 18),
              for (final t in kBrainTopics) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 14),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(t.title, style: ppJakarta(15)),
                    const SizedBox(height: 8),
                    Text(t.body, style: ppBody(13.5, h: 1.55)),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: ppPurple.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(12)),
                      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        const Icon(Icons.lightbulb_outline_rounded, size: 15, color: ppPurple),
                        const SizedBox(width: 9),
                        Expanded(child: Text(t.tip, style: ppBody(12.5, color: ppInk, h: 1.5))),
                      ]),
                    ),
                  ]),
                ),
              ],
            ]),
          ),
        ),
      ),
    );
  }

  Widget _aheadCard(LookAhead a) => Container(
        width: 230,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(width: 36, height: 36, alignment: Alignment.center, decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(11)), child: Icon(a.icon, size: 18, color: ppPurple)),
          const SizedBox(height: 12),
          Text(a.title, style: ppJakarta(13.5).copyWith(height: 1.2), maxLines: 2, overflow: TextOverflow.ellipsis),
          const SizedBox(height: 5),
          Expanded(child: Text(a.body, style: ppBody(11.5, color: ppSoft, h: 1.4), maxLines: 3, overflow: TextOverflow.ellipsis)),
        ]),
      );

  Widget _checkinCta(BuildContext context) => GestureDetector(
        onTap: () => _push(context, const DevelopmentCheckinScreen()),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
          child: Row(children: [
            Container(width: 44, height: 44, alignment: Alignment.center, decoration: BoxDecoration(color: ppCoral.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(13)), child: const Icon(Icons.favorite_border, size: 21, color: ppCoral)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('A gentle check-in', style: ppJakarta(15)),
                const SizedBox(height: 2),
                Text('A few soft questions - to understand, never to grade or compare.', style: ppBody(12, h: 1.4), maxLines: 2, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 8),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );
}

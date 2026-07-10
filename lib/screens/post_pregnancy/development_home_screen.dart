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
            _pad(ppEyebrow('Skill Development', color: ppPurple)),
            const SizedBox(height: 8),
            _pad(Text('Help Aarav grow', style: ppFraunces(30, h: 1.1))),
            const SizedBox(height: 8),
            _pad(Text('This is where you nurture how Aarav is growing - his thinking, his body, his words and his feelings. Not a checklist to tick off, but a gentle companion: what he is learning right now, and the small, joyful things that help it along.', style: ppBody(14, h: 1.55))),

            // 1 - today's focus
            const SizedBox(height: 24),
            _pad(_focusHero(context, focus)),

            // development map (signature)
            const SizedBox(height: 24),
            _pad(_mapCta(context)),

            // 2 - the four windows (same as the My Child snapshot; no progress bars)
            const SizedBox(height: 30),
            _pad(devSectionHeader('Every part of him, growing')),
            const SizedBox(height: 4),
            _pad(Text('Four windows into how he grows - tap any to go deeper.', style: ppBody(12.5, color: ppMuted))),
            const SizedBox(height: 16),
            _pad(Column(children: [
              _domainCard(context, Icons.psychology_outlined, 'Brain', devAreaById('cognitive')),
              const SizedBox(height: 12),
              _domainCard(context, Icons.child_care_outlined, 'Physical', devAreaById('gross_motor')),
              const SizedBox(height: 12),
              _domainCard(context, Icons.chat_bubble_outline_rounded, 'Language', devAreaById('language')),
              const SizedBox(height: 12),
              _domainCard(context, Icons.favorite_border, 'Emotional', devAreaById('emotional')),
            ])),

            // 4 - today's activities
            const SizedBox(height: 30),
            _pad(devSectionHeader("Try together today")),
            const SizedBox(height: 4),
            _pad(Text('Small, joyful things that support exactly where he is.', style: ppBody(12.5, color: ppMuted))),
            const SizedBox(height: 16),
            _pad(Column(children: [for (final a in activities) DevActivityCard(activity: a, onTap: () => _push(context, DevelopmentActivityScreen(activity: a)))])),

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

  // ---- one of the four "how he grows" windows (matches My Child snapshot) --
  Widget _domainCard(BuildContext context, IconData icon, String label, DevArea a) => GestureDetector(
        onTap: () => _push(context, DevelopmentAreaScreen(area: a)),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair), boxShadow: const [BoxShadow(color: Color(0x0F6A30B6), blurRadius: 18, spreadRadius: -14, offset: Offset(0, 8))]),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: a.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(icon, size: 19, color: a.accent)),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(label.toUpperCase(), style: ppBody(9.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.6)),
                const SizedBox(height: 2),
                Text(a.stage, style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis),
              ])),
              const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
            ]),
            const SizedBox(height: 12),
            Text(a.summary, style: ppBody(13, h: 1.5)),
          ]),
        ),
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

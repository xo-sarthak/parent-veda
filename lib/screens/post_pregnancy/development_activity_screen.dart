// =============================================================================
//  DevelopmentActivityScreen - one activity to try together
// -----------------------------------------------------------------------------
//  Duration, materials, difficulty, the skills it supports, how to do it, safety
//  notes and the developmental benefit - plus save and "we did this" (a quiet
//  celebration, never a streak). Warm and doable, not clinical.
// =============================================================================

import 'package:flutter/material.dart';

import 'development_area_screen.dart';
import 'pp_common.dart';
import 'pp_development_data.dart';

class DevelopmentActivityScreen extends StatelessWidget {
  const DevelopmentActivityScreen({super.key, required this.activity});
  final DevActivity activity;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _push(BuildContext c, Widget s) => Navigator.of(c).push(MaterialPageRoute<void>(builder: (_) => s));

  @override
  Widget build(BuildContext context) {
    final area = devAreaById(activity.areaId);
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 40),
          children: [
            // hero band
            Container(
              decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [area.accent.withValues(alpha: 0.16), area.accent.withValues(alpha: 0.05)])),
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 22),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                ppBack(context, area.name),
                const SizedBox(height: 14),
                Container(width: 48, height: 48, alignment: Alignment.center, decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15)), child: Icon(area.icon, size: 24, color: area.accent)),
                const SizedBox(height: 14),
                Text(activity.title, style: ppFraunces(25, h: 1.15)),
                const SizedBox(height: 10),
                Row(children: [
                  Icon(Icons.schedule_rounded, size: 14, color: area.accent),
                  const SizedBox(width: 5),
                  Text('${activity.minutes} min', style: ppBody(12.5, color: ppInk, w: FontWeight.w600)),
                  const SizedBox(width: 12),
                  Text('${activity.difficulty}  ·  ${activity.ageTag}', style: ppBody(12.5, color: ppSoft, w: FontWeight.w600)),
                ]),
              ]),
            ),
            const SizedBox(height: 18),
            _pad(_actions(area.accent)),
            const SizedBox(height: 20),

            // skills
            _pad(Text('Skills this supports', style: ppJakarta(16))),
            const SizedBox(height: 12),
            _pad(Wrap(spacing: 8, runSpacing: 8, children: [
              for (final s in activity.skills)
                Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7), decoration: BoxDecoration(color: area.accent.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(999)), child: Text(s, style: ppBody(12, color: area.accent, w: FontWeight.w700))),
            ])),

            const SizedBox(height: 22),
            _pad(_materials()),

            const SizedBox(height: 22),
            _pad(Text('How to do it', style: ppJakarta(16))),
            const SizedBox(height: 14),
            _pad(Column(children: [
              for (int i = 0; i < activity.steps.length; i++)
                Padding(
                  padding: const EdgeInsets.only(bottom: 14),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Container(width: 26, height: 26, alignment: Alignment.center, decoration: BoxDecoration(color: area.accent.withValues(alpha: 0.12), shape: BoxShape.circle), child: Text('${i + 1}', style: ppBody(12.5, color: area.accent, w: FontWeight.w800))),
                    const SizedBox(width: 13),
                    Expanded(child: Text(activity.steps[i], style: ppBody(14, color: ppInk, h: 1.5))),
                  ]),
                ),
            ])),

            const SizedBox(height: 8),
            _pad(_safety()),
            const SizedBox(height: 20),
            _pad(Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: area.accent.withValues(alpha: 0.07), borderRadius: BorderRadius.circular(18)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [Icon(Icons.eco_outlined, size: 16, color: area.accent), const SizedBox(width: 8), ppEyebrow('Why it helps him grow', color: area.accent, spacing: 0.8)]),
                const SizedBox(height: 10),
                Text(activity.benefit, style: ppBody(14, color: ppInk, h: 1.6)),
              ]),
            )),
            const SizedBox(height: 18),
            _pad(GestureDetector(
              onTap: () => _push(context, DevelopmentAreaScreen(area: area)),
              behavior: HitTestBehavior.opaque,
              child: Row(children: [
                Text('See the ${area.name} journey', style: ppBody(13, color: ppPurple, w: FontWeight.w700)),
                const SizedBox(width: 6),
                const Icon(Icons.arrow_forward, size: 15, color: ppPurple),
              ]),
            )),
          ],
        ),
      ),
    );
  }

  Widget _actions(Color accent) => AnimatedBuilder(
        animation: DevStore.instance,
        builder: (context, _) {
          final saved = DevStore.instance.isSaved(activity.id);
          final done = DevStore.instance.isCompleted(activity.id);
          return Row(children: [
            Expanded(
              child: GestureDetector(
                onTap: () => DevStore.instance.toggleComplete(activity.id),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 13),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: done ? accent.withValues(alpha: 0.12) : accent, borderRadius: BorderRadius.circular(14)),
                  child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(done ? Icons.check_circle_rounded : Icons.check_rounded, size: 18, color: done ? accent : Colors.white),
                    const SizedBox(width: 8),
                    Text(done ? 'We did this' : 'We did this', style: ppBody(13.5, color: done ? accent : Colors.white, w: FontWeight.w700)),
                  ]),
                ),
              ),
            ),
            const SizedBox(width: 12),
            GestureDetector(
              onTap: () => DevStore.instance.toggleSave(activity.id),
              behavior: HitTestBehavior.opaque,
              child: Container(
                width: 50,
                height: 48,
                alignment: Alignment.center,
                decoration: BoxDecoration(borderRadius: BorderRadius.circular(14), border: Border.all(color: ppBorder)),
                child: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded, size: 21, color: saved ? ppPurple : ppSoft),
              ),
            ),
          ]);
        },
      );

  Widget _materials() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('What you’ll need', style: ppJakarta(16)),
        const SizedBox(height: 12),
        for (final m in activity.materials)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Icon(Icons.check_circle_outline_rounded, size: 16, color: ppPurple),
              const SizedBox(width: 12),
              Expanded(child: Text(m, style: ppBody(14, color: ppInk, h: 1.4))),
            ]),
          ),
      ]);

  Widget _safety() => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: ppCoralTint, borderRadius: BorderRadius.circular(16)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [const Icon(Icons.shield_outlined, size: 16, color: ppCoral), const SizedBox(width: 8), Text('Keep it safe', style: ppBody(12.5, color: ppInk, w: FontWeight.w800))]),
          const SizedBox(height: 10),
          for (final s in activity.safety)
            Padding(
              padding: const EdgeInsets.only(bottom: 6),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('·  ', style: ppBody(13, color: ppCoral, w: FontWeight.w800)),
                Expanded(child: Text(s, style: ppBody(13, color: ppInk, h: 1.45))),
              ]),
            ),
        ]),
      );
}

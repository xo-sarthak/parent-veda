// =============================================================================
//  CoursesScreen - Learn · Documentary Courses (parenting · S14)
// -----------------------------------------------------------------------------
//  RETIRED (superseded 2026-07) - folded into the merged "Courses &
//  Masterclasses" section: see learning_home_screen.dart (LearningHomeScreen).
//  This landing page is no longer wired into the Explore drawer. The code is
//  kept intact (not deleted) because pp_common.dart still references
//  `CoursesScreen` as the ppDeeperRow fallback, and the focused-course flow lives
//  on in CourseDetailScreen / CourseLessonScreen (now wrapped by a
//  LearningProgram). Safe to remove once those references are repointed.
// -----------------------------------------------------------------------------
//  The flagship "Complete Parenting Guide" (pregnancy → age 12) that unlocks
//  stage by stage, plus a second specialist course. You only see modules for
//  the child's current stage; the rest are a tap away. Reached from the Explore
//  drawer (design path: Products → Learn → Courses). Faithful build of S14.
// =============================================================================

import 'package:flutter/material.dart';
import 'pp_child_profile.dart';

import 'course_detail_screen.dart';
import 'course_funnel_screen.dart';
import 'pp_common.dart';
import 'pp_courses_data.dart';

class CoursesScreen extends StatelessWidget {
  const CoursesScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _openFunnel(BuildContext context) =>
      Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CourseFunnelScreen()));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: Stack(children: [
        SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              ppBack(context, 'Explore'),
              ppLangToggle(),
            ])),

            const SizedBox(height: 22),
            _pad(Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              ppEyebrow('Documentary courses'),
              const SizedBox(height: 10),
              Text('Courses', style: ppFraunces(32, h: 1.12)),
              const SizedBox(height: 12),
              Text(
                  "Deep, documentary-style guides that unlock stage by stage - you only see what's relevant to ${ChildProfileStore.instance.name} right now, with everything else a tap away.",
                  style: ppBody(15)),
            ])),

            // featured flagship
            const SizedBox(height: 22),
            _pad(Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: ppBorder),
                boxShadow: ppCardShadow,
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Stack(children: [
                  const PpStriped(height: 160),
                  Positioned(
                    top: 14,
                    left: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(999)),
                      child: Text('Flagship', style: ppBody(11, color: Colors.white, w: FontWeight.w700)),
                    ),
                  ),
                ]),
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _vetted('Expert-vetted'),
                    const SizedBox(height: 12),
                    Text('The Complete Parenting Guide', style: ppFraunces(24, h: 1.15)),
                    const SizedBox(height: 10),
                    Text('Pregnancy through age 12 - every stage, taught properly, once. It grows up alongside your child.',
                        style: ppBody(14, h: 1.55)),
                    const SizedBox(height: 16),
                    Row(children: [
                      _stat('140+', 'modules'),
                      _statDivider(),
                      _stat('Stage', 'personalised'),
                      _statDivider(),
                      _stat('∞', 'lifetime access'),
                    ]),
                    const SizedBox(height: 18),
                    Row(children: [
                      Expanded(
                        child: Text.rich(TextSpan(children: [
                          TextSpan(text: '₹4,999', style: ppBody(16, color: ppInk, w: FontWeight.w700)),
                          TextSpan(text: '  ·  free on ParentVeda+', style: ppBody(12, color: ppSoft)),
                        ])),
                      ),
                      const SizedBox(width: 12),
                      GestureDetector(
                        onTap: () => _openFunnel(context),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 11),
                          decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                          child: Text('Preview', style: ppBody(13, color: Colors.white, w: FontWeight.w700)),
                        ),
                      ),
                    ]),
                  ]),
                ),
              ]),
            )),

            // stage-personalised modules
            const SizedBox(height: 24),
            _pad(Container(
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 18),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  ppEyebrow('Unlocked for ${ChildProfileStore.instance.name} now', color: ppBrown, spacing: 0.8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999)),
                    child: Text('4 months', style: ppBody(11, color: ppInk, w: FontWeight.w700)),
                  ),
                ]),
                const SizedBox(height: 8),
                Text('You see this stage. Earlier and later modules are always a tap away.',
                    style: ppBody(13, h: 1.5)),
                const SizedBox(height: 6),
                _module(context, Icons.play_arrow_rounded, 'The 4-month brain',
                    '18 min · playing now for you',
                    top: true),
                _module(context, Icons.play_arrow_rounded, 'Surviving the sleep regression', '22 min'),
                _module(context, Icons.lock_outline_rounded, 'First solids, step by step',
                    'Unlocks at 6 months · open anyway',
                    locked: true),
              ]),
            )),

            // second course
            const SizedBox(height: 28),
            _pad(Text('Also on ParentVeda', style: ppJakarta(18))),
            const SizedBox(height: 14),
            _pad(Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(22),
                border: Border.all(color: ppBorder),
              ),
              clipBehavior: Clip.antiAlias,
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const PpStriped(height: 130),
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  padding: const EdgeInsets.all(18),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    _vetted('Specialist-vetted'),
                    const SizedBox(height: 12),
                    Text('Parenting a Child with Special Needs', style: ppJakarta(18)),
                    const SizedBox(height: 8),
                    Text(
                        'An autism-focused course, made with developmental specialists - with ADHD & learning differences coming next.',
                        style: ppBody(13, h: 1.55)),
                    const SizedBox(height: 12),
                    Text.rich(TextSpan(children: [
                      TextSpan(text: '₹4,999', style: ppBody(15, color: ppInk, w: FontWeight.w700)),
                      TextSpan(text: '  ·  free on ParentVeda+', style: ppBody(12, color: ppSoft)),
                    ])),
                  ]),
                ),
              ]),
            )),

            // focused short courses
            const SizedBox(height: 28),
            _pad(Text('Focused courses', style: ppJakarta(18))),
            const SizedBox(height: 4),
            _pad(Text('Short, single-topic courses - start one in a spare few minutes.', style: ppBody(13, color: ppMuted))),
            const SizedBox(height: 14),
            _pad(Column(children: [for (final c in kCourses) _focusedCourse(context, c)])),

            // how it's made
            const SizedBox(height: 18),
            _pad(Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.movie_outlined, size: 18, color: ppPurple),
                const SizedBox(width: 11),
                Expanded(
                  child: Text(
                      "Told through ParentVeda's own animated guides - scripted from research and approved by paediatricians & child psychologists before anything reaches you.",
                      style: ppBody(13, color: ppInk, h: 1.5)),
                ),
              ]),
            )),

            const SizedBox(height: 22),
            _pad(Text(
                "You only see what fits your child's age - everything else waits, one tap away. Free with ParentVeda+.",
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
          ],
        ),
      ),
      ]),
    );
  }

  Widget _vetted(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: const Color(0xFFEAF6EF), borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_rounded, size: 12, color: Color(0xFF1F8A5B)),
          const SizedBox(width: 5),
          Text(label, style: ppBody(11, color: const Color(0xFF1F8A5B), w: FontWeight.w700)),
        ]),
      );

  Widget _stat(String value, String label) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: ppJakarta(16)),
          const SizedBox(height: 2),
          Text(label, style: ppBody(11, color: ppMuted)),
        ]),
      );

  Widget _statDivider() => Container(
        width: 1,
        height: 30,
        color: ppLine,
        margin: const EdgeInsets.symmetric(horizontal: 12),
      );

  Widget _module(BuildContext context, IconData icon, String title, String meta,
      {bool locked = false, bool top = false}) {
    return GestureDetector(
      onTap: () => _openFunnel(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(top: top ? const BorderSide(color: ppPanelDiv) : BorderSide.none),
        ),
        child: Row(children: [
          Container(
            width: 38,
            height: 38,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
            child: Icon(icon, size: 17, color: locked ? ppMuted : ppPurple),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(title, style: ppBody(14, color: ppInk, w: FontWeight.w600)),
              const SizedBox(height: 2),
              Text(meta, style: ppBody(12, color: ppMuted)),
            ]),
          ),
        ]),
      ),
    );
  }

  Widget _focusedCourse(BuildContext context, Course c) => GestureDetector(
        onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => CourseDetailScreen(course: c))),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
          child: Row(children: [
            Container(width: 40, height: 40, alignment: Alignment.center, decoration: BoxDecoration(color: c.accent.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(12)), child: Icon(Icons.play_circle_outline, size: 20, color: c.accent)),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(c.title, style: ppJakarta(15)),
                const SizedBox(height: 2),
                Text('${c.lessons.length} lessons · ~${c.totalMinutes} min · ${c.ageTag}', style: ppBody(12, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 20, color: ppMuted),
          ]),
        ),
      );
}

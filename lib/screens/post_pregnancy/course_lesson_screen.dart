// =============================================================================
//  CourseLessonScreen - one lesson (module) inside a focused course
// -----------------------------------------------------------------------------
//  The real destination for a lesson row (or "Preview this course") on a focused
//  CourseDetailScreen - so a module opens ITS OWN page inside the RIGHT course,
//  never the flagship funnel. There is no video engine yet, so this is honestly
//  marked as a preview: the outline is final, the film is in production/review.
//  It borrows its visual language from the course / masterclass / cohort funnels
//  (hero + play disc, vetted row, "what you'll take away", up-next), so the flow
//  feels complete even though the lesson itself is not yet reviewed.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_courses_data.dart';

class CourseLessonScreen extends StatelessWidget {
  const CourseLessonScreen({super.key, required this.course, required this.index});
  final Course course;
  final int index;

  CourseLesson get lesson => course.lessons[index];
  int get _count => course.lessons.length;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _snack(BuildContext context, String msg) => ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating),
      );

  // The lesson name without its "Module N · " prefix, for natural sentences.
  String get _name => lesson.title.contains('·') ? lesson.title.split('·').last.trim() : lesson.title;

  List<String> get _takeaways => [
        '$_name, explained simply - the what and the why',
        "How it fits your baby's stage (${course.ageTag})",
        'Small, doable things that help this week',
      ];

  @override
  Widget build(BuildContext context) {
    final a = course.accent;
    final hasNext = index + 1 < _count;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, course.title)),

            const SizedBox(height: 18),
            _pad(ppEyebrow('Lesson ${index + 1} of $_count · ${course.title}', color: a, spacing: 1.1)),
            const SizedBox(height: 8),
            _pad(Text(lesson.title, style: ppFraunces(29, h: 1.14))),
            const SizedBox(height: 12),
            _pad(Row(children: [
              const Icon(Icons.schedule_rounded, size: 14, color: ppMuted),
              const SizedBox(width: 6),
              Text('${lesson.minutes} min', style: ppBody(12.5, color: ppSoft, w: FontWeight.w600)),
              const SizedBox(width: 12),
              Icon(lesson.locked ? Icons.lock_outline_rounded : Icons.play_circle_outline, size: 14, color: ppMuted),
              const SizedBox(width: 6),
              Flexible(child: Text(lesson.locked ? 'Unlocks later · open anyway' : 'Preview available',
                  style: ppBody(12.5, color: ppSoft, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
            ])),

            // video-preview hero (no engine yet - honest tap)
            const SizedBox(height: 18),
            _pad(GestureDetector(
              onTap: () => _snack(context, "This lesson's film is in production - the outline below is final."),
              behavior: HitTestBehavior.opaque,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(children: [
                  const PpStriped(height: 190, radius: 22, border: true),
                  Positioned.fill(child: Center(child: _PlayDisc(54, a))),
                  Positioned(
                    left: 14,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(999)),
                      child: Text('Preview this lesson', style: ppBody(11, color: Colors.white, w: FontWeight.w600)),
                    ),
                  ),
                ]),
              ),
            )),

            // honest "in review" notice - this template is new; the film isn't live
            const SizedBox(height: 18),
            _pad(Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: a.withValues(alpha: 0.08), borderRadius: BorderRadius.circular(16)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Icon(Icons.fact_check_outlined, size: 17, color: a),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('Preview lesson', style: ppBody(13, color: ppInk, w: FontWeight.w800)),
                    const SizedBox(height: 3),
                    Text('The lesson outline is final. The film is being produced and reviewed by our experts before it goes live.',
                        style: ppBody(12.5, color: ppInk, h: 1.5)),
                  ]),
                ),
              ]),
            )),

            // what you'll take away
            _pad(ppSectionDivider()),
            _pad(Text('What you\'ll take away', style: ppJakarta(17))),
            const SizedBox(height: 12),
            _pad(Column(children: [
              for (final t in _takeaways)
                Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Icon(Icons.check_circle_outline_rounded, size: 17, color: a),
                    const SizedBox(width: 11),
                    Expanded(child: Text(t, style: ppBody(14, color: ppInk, h: 1.45))),
                  ]),
                ),
            ])),

            // vetted-by (same trust line as the course page)
            const SizedBox(height: 12),
            _pad(Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.verified_user_outlined, size: 17, color: ppPurple),
                const SizedBox(width: 11),
                Expanded(child: Text('${course.expert}. Scripted from research and reviewed before anything reaches you.',
                    style: ppBody(13, color: ppInk, h: 1.55))),
              ]),
            )),

            // up next
            if (hasNext) ...[
              _pad(ppSectionDivider()),
              _pad(Text('Up next', style: ppJakarta(16))),
              const SizedBox(height: 12),
              _pad(GestureDetector(
                // pushReplacement keeps the lesson stack shallow when moving on
                onTap: () => Navigator.of(context).pushReplacement(
                    MaterialPageRoute<void>(builder: (_) => CourseLessonScreen(course: course, index: index + 1))),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: ppHair)),
                  child: Row(children: [
                    Container(
                      width: 34,
                      height: 34,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(color: a.withValues(alpha: 0.12), shape: BoxShape.circle),
                      child: Icon(Icons.play_arrow_rounded, size: 17, color: a),
                    ),
                    const SizedBox(width: 13),
                    Expanded(
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        Text('Lesson ${index + 2}', style: ppBody(11, color: ppMuted, w: FontWeight.w700)),
                        const SizedBox(height: 1),
                        Text(course.lessons[index + 1].title, style: ppBody(14, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                      ]),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: ppMuted),
                  ]),
                ),
              )),
            ],

            // back to the full course
            const SizedBox(height: 20),
            _pad(GestureDetector(
              onTap: () => Navigator.of(context).maybePop(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 50,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppLine)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.arrow_back_rounded, size: 17, color: ppInk),
                  const SizedBox(width: 8),
                  Flexible(child: Text('Back to ${course.title}', style: ppBody(14, color: ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                ]),
              ),
            )),
            const SizedBox(height: 12),
            _pad(Text('Free with ParentVeda+ · lifetime access. Full lessons unlock as they are filmed.',
                textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.5))),
          ],
        ),
      ),
    );
  }
}

class _PlayDisc extends StatelessWidget {
  const _PlayDisc(this.size, this.accent);
  final double size;
  final Color accent;
  @override
  Widget build(BuildContext context) => Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.92), shape: BoxShape.circle),
        child: Icon(Icons.play_arrow_rounded, color: accent, size: size * 0.5),
      );
}

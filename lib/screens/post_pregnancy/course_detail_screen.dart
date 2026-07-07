// =============================================================================
//  CourseDetailScreen - one focused course, in full
// -----------------------------------------------------------------------------
//  The real destination for a "Go deeper · Course" row: what the course is, who
//  vetted it, its lessons (with the referenced one marked "Start here"), and a
//  preview CTA. Reached from the Go-Deeper rows and the Courses screen. Lesson
//  playback previews through the existing course funnel (video engine is future).
// =============================================================================

import 'package:flutter/material.dart';

import 'course_funnel_screen.dart';
import 'pp_common.dart';
import 'pp_courses_data.dart';

class CourseDetailScreen extends StatelessWidget {
  const CourseDetailScreen({super.key, required this.course, this.highlight});
  final Course course;
  final String? highlight; // the Go-Deeper text, to mark a "start here" lesson

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);
  void _preview(BuildContext context) => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const CourseFunnelScreen()));

  @override
  Widget build(BuildContext context) {
    final startAt = highlight != null ? lessonIndexForDeeperText(course, highlight!) : -1;
    final a = course.accent;
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.only(top: 12, bottom: 40),
          children: [
            _pad(ppBack(context, 'Courses')),

            const SizedBox(height: 18),
            _pad(Row(children: [
              _vetted(),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                child: Text(course.ageTag, style: ppBody(11, color: ppInk, w: FontWeight.w700)),
              ),
            ])),
            const SizedBox(height: 14),
            _pad(ppEyebrow('Focused course', color: a, spacing: 1.2)),
            const SizedBox(height: 8),
            _pad(Text(course.title, style: ppFraunces(31, h: 1.12))),
            const SizedBox(height: 10),
            _pad(Text(course.tagline, style: ppBody(15, h: 1.55, color: ppInk))),

            const SizedBox(height: 16),
            _pad(Row(children: [
              _meta('${course.lessons.length}', 'lessons'),
              _metaDiv(),
              _meta('~${course.totalMinutes}', 'minutes'),
              _metaDiv(),
              _meta('∞', 'lifetime access'),
            ])),

            const SizedBox(height: 18),
            _pad(Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: a.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16)),
              child: Text(course.about, style: ppBody(14, color: ppInk, h: 1.6)),
            )),

            _pad(ppSectionDivider()),
            _pad(Text('What you\'ll learn', style: ppJakarta(17))),
            const SizedBox(height: 6),
            _pad(Text('Short lessons, in order - start anywhere.', style: ppBody(12.5, color: ppMuted))),
            const SizedBox(height: 14),
            _pad(Column(children: [
              for (int i = 0; i < course.lessons.length; i++)
                _lessonRow(context, course.lessons[i], i, first: i == 0, startHere: i == startAt, accent: a),
            ])),

            const SizedBox(height: 22),
            _pad(Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.verified_user_outlined, size: 17, color: ppPurple),
                const SizedBox(width: 11),
                Expanded(child: Text('${course.expert}. Scripted from research and reviewed before anything reaches you.', style: ppBody(13, color: ppInk, h: 1.55))),
              ]),
            )),

            const SizedBox(height: 18),
            _pad(GestureDetector(
              onTap: () => _preview(context),
              behavior: HitTestBehavior.opaque,
              child: Container(
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16), boxShadow: const [BoxShadow(color: Color(0x8C6A30B6), blurRadius: 28, spreadRadius: -10, offset: Offset(0, 12))]),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.play_circle_outline, size: 19, color: Colors.white),
                  const SizedBox(width: 8),
                  Text('Preview this course', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                ]),
              ),
            )),
            const SizedBox(height: 12),
            _pad(Text('Free with ParentVeda+ · lifetime access.', textAlign: TextAlign.center, style: ppBody(12, color: ppMuted))),
          ],
        ),
      ),
    );
  }

  Widget _vetted() => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: const Color(0xFFEAF6EF), borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.check_rounded, size: 12, color: Color(0xFF1F8A5B)),
          const SizedBox(width: 5),
          Text('Expert-vetted', style: ppBody(11, color: const Color(0xFF1F8A5B), w: FontWeight.w700)),
        ]),
      );

  Widget _meta(String value, String label) => Expanded(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(value, style: ppJakarta(16)),
          const SizedBox(height: 2),
          Text(label, style: ppBody(11, color: ppMuted)),
        ]),
      );

  Widget _metaDiv() => Container(width: 1, height: 30, color: ppLine, margin: const EdgeInsets.symmetric(horizontal: 12));

  Widget _lessonRow(BuildContext context, CourseLesson l, int i, {bool first = false, bool startHere = false, required Color accent}) {
    return GestureDetector(
      onTap: () => _preview(context),
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          border: Border(top: first ? BorderSide.none : const BorderSide(color: ppHair)),
        ),
        child: Row(children: [
          Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: l.locked ? ppPanel : accent.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(l.locked ? Icons.lock_outline_rounded : Icons.play_arrow_rounded, size: 17, color: l.locked ? ppMuted : accent),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Flexible(child: Text(l.title, style: ppBody(14, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                if (startHere) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(color: accent, borderRadius: BorderRadius.circular(999)),
                    child: Text('Start here', style: ppBody(9.5, color: Colors.white, w: FontWeight.w800)),
                  ),
                ],
              ]),
              const SizedBox(height: 2),
              Text(l.locked ? '${l.minutes} min · unlocks later, open anyway' : '${l.minutes} min', style: ppBody(12, color: ppMuted)),
            ]),
          ),
          const Icon(Icons.chevron_right_rounded, size: 18, color: ppMuted),
        ]),
      ),
    );
  }
}

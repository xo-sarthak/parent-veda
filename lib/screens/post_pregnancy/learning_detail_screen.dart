// =============================================================================
//  LearningDetailScreen - one program, in full (parenting · unified Learning)
// -----------------------------------------------------------------------------
//  The single detail page behind every card in the merged "Courses &
//  Masterclasses" section - live cohorts, recorded courses and masterclasses all
//  share this rich layout: hero, instructor, schedule/lessons, what's covered, a
//  testimonial, and a business-logic CTA (Reserve / Buy / Join live / Watch now /
//  locked "Cohort in progress"). Every detail ends with a "More by {instructor}"
//  list. Paying is a mock confirmation sheet; recorded courses still open their
//  own CourseLessonScreen for the lesson itself.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_catalog.dart';
import 'booking_sheet.dart';
import 'course_lesson_screen.dart';
import 'pp_common.dart';
import 'pp_courses_data.dart';
import 'pp_learning_data.dart';
import 'provider_profile_screen.dart';

class LearningDetailScreen extends StatefulWidget {
  const LearningDetailScreen({super.key, required this.program});
  final LearningProgram program;

  @override
  State<LearningDetailScreen> createState() => _LearningDetailScreenState();
}

class _LearningDetailScreenState extends State<LearningDetailScreen> {
  LearningProgram get p => widget.program;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _openExpert() => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => ProviderProfileScreen(expert: p.instructor)));

  void _openProgram(LearningProgram other) => Navigator.of(context)
      .push(MaterialPageRoute<void>(builder: (_) => LearningDetailScreen(program: other)));

  void _openLesson(int i) {
    final course = p.course;
    if (course == null) return;
    Navigator.of(context)
        .push(MaterialPageRoute<void>(builder: (_) => CourseLessonScreen(course: course, index: i)));
  }

  void _snack(String msg) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg), behavior: SnackBarBehavior.floating));

  // --- CTA action -------------------------------------------------------
  void _onCta(LearningCta cta) {
    if (!cta.enabled) {
      _snack('This cohort has already started - reserve the next intake.');
      return;
    }
    if (cta.watch) {
      final course = p.course;
      if (course != null) {
        _openLesson(0); // recorded course -> open the first lesson
      } else {
        _snack('Opening your player - the film is in production for now.');
      }
      return;
    }
    // If this program is bridged to the booking engine, run the real
    // buy -> reserve flow; otherwise fall back to the mock paysheet.
    final offering = BookingCatalog.instance.offeringForCatalog(p.id);
    if (offering != null) {
      showBookingSheet(context, offering);
      return;
    }
    _paysheet(cta.label);
  }

  // Mock payment / reservation confirmation.
  void _paysheet(String action) {
    final live = p.isLive;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(99)))),
          const SizedBox(height: 20),
          Container(
            width: 52,
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: p.accent.withValues(alpha: 0.12), shape: BoxShape.circle),
            child: Icon(Icons.check_rounded, size: 26, color: p.accent),
          ),
          const SizedBox(height: 16),
          Text(live ? "You're in" : 'Confirmed', style: ppFraunces(24, h: 1.14)),
          const SizedBox(height: 8),
          Text('$action · ${p.title}', style: ppBody(14, color: ppInk, h: 1.5)),
          const SizedBox(height: 6),
          Text(
              live
                  ? "We'll send a calendar invite and a reminder before it begins."
                  : 'It\'s now in your library - watch anytime, forever.',
              style: ppBody(13, h: 1.55)),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(
                child: Text.rich(TextSpan(children: [
              TextSpan(text: p.price, style: ppBody(16, color: ppInk, w: FontWeight.w700)),
              TextSpan(text: '  ·  ${p.priceNote}', style: ppBody(12, color: ppSoft)),
            ]))),
            GestureDetector(
              onTap: () => Navigator.of(ctx).pop(),
              behavior: HitTestBehavior.opaque,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(14)),
                child: Text('Done', style: ppBody(14, color: Colors.white, w: FontWeight.w700)),
              ),
            ),
          ]),
          const SizedBox(height: 10),
          Text('Mock checkout - no payment is taken in this preview.',
              style: ppBody(11, color: ppMuted), textAlign: TextAlign.left),
        ]),
      ),
    );
  }

  // A reschedule affordance for live programs (mock date picker sheet).
  void _reschedule() {
    const dates = ['Sun 21 Jul', 'Sun 4 Aug', 'Sun 18 Aug'];
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        padding: const EdgeInsets.fromLTRB(24, 14, 24, 30),
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(99)))),
          const SizedBox(height: 18),
          Text('Pick a start date', style: ppFraunces(22, h: 1.16)),
          const SizedBox(height: 4),
          Text('Reserve now, join the intake that suits you.', style: ppBody(13)),
          const SizedBox(height: 14),
          for (final d in dates)
            GestureDetector(
              onTap: () {
                Navigator.of(ctx).pop();
                _snack('Switched to the $d intake.');
              },
              behavior: HitTestBehavior.opaque,
              child: Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: ppHair)),
                child: Row(children: [
                  Icon(Icons.event_outlined, size: 18, color: p.accent),
                  const SizedBox(width: 12),
                  Expanded(child: Text(d, style: ppBody(14, color: ppInk, w: FontWeight.w700))),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: ppMuted),
                ]),
              ),
            ),
        ]),
      ),
    );
  }

  // --- quick facts per kind --------------------------------------------
  List<(String, String)> _facts() {
    switch (p.kind) {
      case LearningKind.liveCohort:
        return [
          (p.durationLabel.split(' ·').first, 'programme'),
          (p.sessionTimes.isNotEmpty ? '2x/week' : 'Live', 'live calls'),
          (p.seatsLeft != null ? '${p.seatsLeft}' : '20', 'seats left'),
        ];
      case LearningKind.masterclass:
        if (p.isLiveScheduled) {
          return [(p.durationLabel, 'live'), ('Live Q&A', 'included'), ('Attendees', 'get recording')];
        }
        return [(p.durationLabel, 'recorded'), ('★ ${p.rating}', 'rated'), ('Forever', 'yours')];
      case LearningKind.recordedCourse:
        final c = p.course;
        if (c != null) {
          return [('${c.lessons.length}', 'lessons'), ('~${c.totalMinutes}', 'minutes'), ('∞', 'lifetime')];
        }
        return [(p.durationLabel, 'course'), ('★ ${p.rating}', 'rated'), ('∞', 'lifetime')];
    }
  }

  @override
  Widget build(BuildContext context) {
    final a = p.accent;
    final cta = ctaFor(p);
    final course = p.course;
    final facts = _facts();
    final more = programsByInstructor(p.instructorId, exclude: p.id);
    final review = p.instructor.reviews.isNotEmpty ? p.instructor.reviews.first : null;

    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 120),
            children: [
              _pad(Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Flexible(child: ppBack(context, 'Courses')),
                ppLangToggle(),
              ])),

              // hero
              const SizedBox(height: 18),
              _pad(ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(children: [
                  PpStriped(height: 200, radius: 22, border: true, colorA: a.withValues(alpha: 0.16), colorB: a.withValues(alpha: 0.05)),
                  Positioned.fill(child: Center(child: _PlayDisc(56, a))),
                  Positioned(
                    left: 14,
                    bottom: 14,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                          color: p.isLive ? ppCoral : ppInk.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(999)),
                      child: Text(p.heroTag, style: ppBody(11, color: Colors.white, w: FontWeight.w700)),
                    ),
                  ),
                ]),
              )),

              // badges
              const SizedBox(height: 18),
              _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                _pill(p.kind.label, a, filled: true),
                for (final t in p.topics.take(2)) _pill(t, a),
              ])),
              const SizedBox(height: 12),
              _pad(Text(p.title, style: ppFraunces(30, h: 1.14))),
              const SizedBox(height: 10),
              _pad(Text(p.subtitle, style: ppBody(15, h: 1.5, color: ppInk))),

              // quick facts
              const SizedBox(height: 20),
              _pad(Row(children: [
                for (int i = 0; i < facts.length; i++) ...[
                  _fact(facts[i].$1, facts[i].$2),
                  if (i != facts.length - 1) const SizedBox(width: 10),
                ],
              ])),

              // about
              const SizedBox(height: 22),
              _pad(Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: a.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(16)),
                child: Text(p.about, style: ppBody(14, color: ppInk, h: 1.6)),
              )),

              // instructor
              const SizedBox(height: 26),
              _pad(Row(children: [
                Expanded(child: Text(p.isLive ? 'Your coach' : 'Your instructor', style: ppJakarta(18))),
                GestureDetector(
                  onTap: _openExpert,
                  behavior: HitTestBehavior.opaque,
                  child: Text('View profile →', style: ppBody(12, color: ppPurple, w: FontWeight.w700)),
                ),
              ])),
              const SizedBox(height: 14),
              _pad(GestureDetector(
                onTap: _openExpert,
                behavior: HitTestBehavior.opaque,
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
                    clipBehavior: Clip.antiAlias,
                    child: const PpStriped(height: 70, colorA: ppBorder, colorB: ppStripeB),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(p.instructor.name, style: ppJakarta(16)),
                      const SizedBox(height: 2),
                      Text(p.instructor.credential, style: ppBody(12)),
                      const SizedBox(height: 8),
                      Text(p.instructor.why, style: ppBody(13, h: 1.55), maxLines: 4, overflow: TextOverflow.ellipsis),
                    ]),
                  ),
                ]),
              )),

              // recorded-course lessons (wrapped Course model)
              if (course != null) ...[
                _pad(ppSectionDivider()),
                _pad(Text("What you'll learn", style: ppJakarta(17))),
                const SizedBox(height: 6),
                _pad(Text('Short lessons, in order - start anywhere.', style: ppBody(12.5, color: ppMuted))),
                const SizedBox(height: 12),
                _pad(Column(children: [
                  for (int i = 0; i < course.lessons.length; i++)
                    _lessonRow(course.lessons[i], i, first: i == 0, accent: a),
                ])),
              ],

              // live schedule
              if (p.isLive && (p.sessions.isNotEmpty || p.sessionTimes.isNotEmpty)) ...[
                _pad(ppSectionDivider()),
                _pad(Text(p.isCohort ? 'Your schedule' : 'When it runs', style: ppJakarta(18))),
                if (p.sessionTimes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _pad(Row(children: [
                    const Icon(Icons.videocam_outlined, size: 15, color: ppSoft),
                    const SizedBox(width: 7),
                    Expanded(child: Text(p.sessionTimes.join('  ·  '), style: ppBody(13))),
                  ])),
                ],
                const SizedBox(height: 14),
                for (final s in p.sessions) ...[_pad(_sessionCard(s, a)), const SizedBox(height: 12)],
                if (cta.showReschedule && cta.enabled)
                  _pad(GestureDetector(
                    onTap: _reschedule,
                    behavior: HitTestBehavior.opaque,
                    child: Row(children: [
                      Icon(Icons.event_repeat_outlined, size: 16, color: a),
                      const SizedBox(width: 8),
                      Text('Prefer another date? Reschedule', style: ppBody(13, color: a, w: FontWeight.w700)),
                      const SizedBox(width: 4),
                      Icon(Icons.arrow_forward, size: 13, color: a),
                    ]),
                  )),
              ],

              // what this covers
              if (p.covers.isNotEmpty) ...[
                _pad(ppSectionDivider()),
                _pad(Text('What this covers', style: ppJakarta(18))),
                const SizedBox(height: 6),
                _pad(Column(children: [
                  for (int i = 0; i < p.covers.length; i++) _coversRow(p.covers[i], top: i == 0),
                ])),
              ],

              // walk away with
              if (p.takeaways.isNotEmpty) ...[
                const SizedBox(height: 24),
                _pad(Container(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    ppEyebrow("What you'll walk away with", color: ppBrown, spacing: 0.8),
                    const SizedBox(height: 14),
                    for (final t in p.takeaways)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Icon(Icons.check_rounded, size: 18, color: ppPurple),
                          const SizedBox(width: 10),
                          Expanded(child: Text(t, style: ppBody(14, color: ppInk, h: 1.5))),
                        ]),
                      ),
                  ]),
                )),
              ],

              // testimonial
              if (review != null) ...[
                const SizedBox(height: 26),
                _pad(Row(children: [
                  Text('★ ${p.rating}', style: ppBody(15, color: ppCoral, w: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Text(p.reviewsLabel, style: ppBody(13, color: ppMuted)),
                ])),
                const SizedBox(height: 12),
                _pad(Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: const Color(0xFFECE5F2))),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('★★★★★', style: ppBody(13, color: ppCoral, w: FontWeight.w700)),
                    const SizedBox(height: 10),
                    Text(review.$3, style: ppBody(15, color: ppInk, h: 1.55)),
                    const SizedBox(height: 10),
                    Text.rich(TextSpan(children: [
                      TextSpan(text: '${review.$1} ', style: ppBody(13, color: ppInk, w: FontWeight.w700)),
                      TextSpan(text: '· ${review.$2}', style: ppBody(13, color: ppMuted)),
                    ])),
                  ]),
                )),
              ],

              // guarantee (paid programs)
              if (!cta.watch) ...[
                const SizedBox(height: 28),
                _pad(ppEyebrow('The ParentVeda promise', color: ppBrown, spacing: 0.8)),
                const SizedBox(height: 16),
                _pad(ppGuaranteeRow()),
              ],

              // more by this instructor
              if (more.isNotEmpty) ...[
                _pad(ppSectionDivider()),
                _pad(Text('More by ${p.instructor.name}', style: ppJakarta(18))),
                const SizedBox(height: 12),
                _pad(Column(children: [
                  for (int i = 0; i < more.length; i++) _moreRow(more[i], first: i == 0),
                ])),
              ],

              const SizedBox(height: 20),
              _pad(Text('Led by a verified expert. ${p.priceNote[0].toUpperCase()}${p.priceNote.substring(1)}.',
                  textAlign: TextAlign.center, style: ppBody(12, color: ppMuted, h: 1.55))),
            ],
          ),

          Positioned(left: 0, right: 0, bottom: 0, child: _ctaBar(cta)),
        ]),
      ),
    );
  }

  // --- small parts ------------------------------------------------------
  Widget _pill(String t, Color a, {bool filled = false}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: filled ? a : a.withValues(alpha: 0.10),
          borderRadius: BorderRadius.circular(999),
        ),
        child: Text(t, style: ppBody(11, color: filled ? Colors.white : a, w: FontWeight.w700)),
      );

  Widget _fact(String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: ppJakarta(15), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label, style: ppBody(11, color: ppMuted), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      );

  Widget _lessonRow(CourseLesson l, int i, {bool first = false, required Color accent}) => GestureDetector(
        onTap: () => _openLesson(i),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(border: Border(top: first ? BorderSide.none : const BorderSide(color: ppHair))),
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
                Text(l.title, style: ppBody(14, color: ppInk, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(l.locked ? '${l.minutes} min · unlocks later, open anyway' : '${l.minutes} min', style: ppBody(12, color: ppMuted)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: ppMuted),
          ]),
        ),
      );

  Widget _sessionCard(LearningSession s, Color a) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            ppEyebrow(s.label, color: a, spacing: 1.0),
            const Spacer(),
            const Icon(Icons.schedule_rounded, size: 14, color: ppSoft),
            const SizedBox(width: 5),
            Flexible(child: Text(s.when, textAlign: TextAlign.right, style: ppBody(11, color: ppSoft, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
          ]),
          const SizedBox(height: 8),
          Text(s.title, style: ppJakarta(16)),
          if (s.points.isNotEmpty) const SizedBox(height: 10),
          for (final t in s.points)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(margin: const EdgeInsets.only(top: 7), width: 5, height: 5, decoration: BoxDecoration(color: a, shape: BoxShape.circle)),
                const SizedBox(width: 11),
                Expanded(child: Text(t, style: ppBody(13, color: ppInk, h: 1.5))),
              ]),
            ),
        ]),
      );

  Widget _coversRow(String t, {bool top = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(border: Border(top: top ? const BorderSide(color: ppHair) : BorderSide.none)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(margin: const EdgeInsets.only(top: 7), width: 5, height: 5, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle)),
          const SizedBox(width: 13),
          Expanded(child: Text(t, style: ppBody(14, color: ppInk, h: 1.55))),
        ]),
      );

  Widget _moreRow(LearningProgram m, {bool first = false}) => GestureDetector(
        onTap: () => _openProgram(m),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(border: Border(top: first ? BorderSide.none : const BorderSide(color: ppHair))),
          child: Row(children: [
            PpStriped(height: 58, width: 74, radius: 14, border: true, colorA: m.accent.withValues(alpha: 0.16), colorB: m.accent.withValues(alpha: 0.05)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(m.title, style: ppBody(15, color: ppInk, w: FontWeight.w600), maxLines: 2, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 3),
                Text('${m.kind.label} · ${m.durationLabel}', style: ppBody(12), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 10),
            Text(m.price, style: ppBody(13, color: ppInk, w: FontWeight.w700)),
          ]),
        ),
      );

  Widget _ctaBar(LearningCta cta) => Container(
        padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00FBF9FE), ppBg], stops: [0, 0.22]),
        ),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          if (cta.note != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(cta.note!, textAlign: TextAlign.center, style: ppBody(11, color: ppSoft, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
          Row(children: [
            Flexible(
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(cta.watch ? 'Included' : p.price, style: ppBody(16, color: ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(cta.watch ? 'on ParentVeda+' : p.priceNote, style: ppBody(11, color: ppPurple, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
              ]),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: GestureDetector(
                onTap: () => _onCta(cta),
                child: Container(
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: cta.enabled ? ppPurple : ppLine, borderRadius: BorderRadius.circular(16)),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    if (!cta.enabled) ...[const Icon(Icons.lock_outline_rounded, size: 16, color: ppMuted), const SizedBox(width: 7)],
                    Flexible(child: Text(cta.label, style: ppBody(15, color: cta.enabled ? Colors.white : ppMuted, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  ]),
                ),
              ),
            ),
          ]),
        ]),
      );
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

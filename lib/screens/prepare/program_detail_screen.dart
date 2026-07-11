// =============================================================================
//  ProgramDetailScreen - one program, in full (Prepare › Courses & Cohorts)
// -----------------------------------------------------------------------------
//  The single detail page behind every card in the merged "Courses & Cohorts"
//  section - recorded courses, live cohorts and masterclasses all share this
//  rich layout: hero, quick facts, about, instructor, lessons/schedule, what's
//  covered, takeaways, a testimonial, and a business-logic CTA (Reserve / Buy /
//  Join / Start watching / locked "Cohort in progress"). Mirrors the
//  post-pregnancy LearningDetailScreen in the mother/purple theme. Booking is the
//  existing mock flow (showPrepareBooking + PrepareStore), so a joined/reserved
//  program reflects back. Recorded lessons open the placeholder video player.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../data/prepare_data.dart';
import '../../services/prepare_store.dart';
import 'prepare_common.dart';
import 'prepare_video_screen.dart';

class ProgramDetailScreen extends StatelessWidget {
  const ProgramDetailScreen({super.key, required this.program});
  final PrepProgram program;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _play(BuildContext context, String title, {String? subtitle, String? blurb}) =>
      Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => PrepareVideoScreen(title: title, subtitle: subtitle, blurb: blurb)));

  void _onCta(BuildContext context, PrepCta cta) {
    final p = program;
    if (!cta.enabled) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('This cohort has already started - reserve the next intake.'),
          behavior: SnackBarBehavior.floating));
      return;
    }
    if (cta.watch) {
      if (p.lessons.isNotEmpty) {
        final l = p.lessons.first;
        _play(context, l.title, subtitle: '${l.minutes} min', blurb: p.subtitle);
      } else {
        _play(context, p.title, subtitle: p.durationLabel, blurb: p.subtitle);
      }
      return;
    }
    showPrepareBooking(
      context,
      id: p.id,
      title: p.title,
      priceLabel: '${p.price} · ${p.priceNote}',
      whenLabel: p.isLive ? p.startLabel : null,
      heading: p.isLive ? 'Reserve your spot' : 'Add to your library',
      cta: cta.label,
    );
  }

  // --- quick facts per kind --------------------------------------------
  List<(String, String)> _facts() {
    final p = program;
    switch (p.kind) {
      case PrepKind.cohort:
        return [
          (p.durationLabel.split(' ·').first, 'programme'),
          ('Live', '+ peer group'),
          (p.seatsLeft != null ? '${p.seatsLeft}' : '20', 'seats left'),
        ];
      case PrepKind.masterclass:
        if (p.isLiveScheduled) {
          return [(p.durationLabel, 'live'), ('Live Q&A', 'included'), ('Forever', 'recording')];
        }
        return [(p.durationLabel, 'recorded'), ('★ ${p.rating}', 'rated'), ('Forever', 'yours')];
      case PrepKind.course:
        if (p.lessons.isNotEmpty) {
          final mins = p.lessons.fold<int>(0, (s, l) => s + l.minutes);
          return [('${p.lessons.length}', 'lessons'), ('~$mins', 'minutes'), ('∞', 'lifetime')];
        }
        return [(p.durationLabel, 'course'), ('★ ${p.rating}', 'rated'), ('∞', 'lifetime')];
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = program;
    final a = p.accent;
    final cta = ctaForPrep(p);
    final facts = _facts();
    final review = p.reviews.isNotEmpty ? p.reviews.first : null;

    return Scaffold(
      backgroundColor: kCanvas,
      body: SafeArea(
        bottom: false,
        child: Stack(children: [
          ListView(
            padding: const EdgeInsets.only(top: 12, bottom: 120),
            children: [
              _pad(pvTopBar(context, backLabel: 'Courses & Cohorts')),

              // hero
              const SizedBox(height: 18),
              _pad(ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: GestureDetector(
                  onTap: () => _play(context, '${p.title} - preview', subtitle: '90-sec preview'),
                  child: Stack(children: [
                    PvStriped(height: 200, radius: 22, colorA: a.withValues(alpha: 0.16), colorB: a.withValues(alpha: 0.05)),
                    Positioned.fill(child: Center(child: _PlayDisc(56, a))),
                    Positioned(
                      left: 14,
                      bottom: 14,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                            color: p.isLive ? kCoral : kInk.withValues(alpha: 0.55),
                            borderRadius: BorderRadius.circular(999)),
                        child: Text(p.heroTag,
                            style: pvBody(Colors.white, 11).copyWith(fontWeight: FontWeight.w700)),
                      ),
                    ),
                  ]),
                ),
              )),

              // badges
              const SizedBox(height: 18),
              _pad(Wrap(spacing: 8, runSpacing: 8, children: [
                _pill(p.kind.label, a, filled: true),
                for (final t in p.topics.take(2)) _pill(t, a),
              ])),
              const SizedBox(height: 12),
              _pad(Text(p.title, style: pvHeroStyle().copyWith(fontSize: 30, height: 1.14))),
              const SizedBox(height: 10),
              _pad(Text(p.subtitle, style: pvBody(kInk, 15).copyWith(height: 1.5))),

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
                child: Text(p.about, style: pvBody(kInk, 14).copyWith(height: 1.6)),
              )),

              // instructor
              const SizedBox(height: 26),
              _pad(Text(p.isLive ? 'Your coach' : 'Your instructor', style: pvTitleStyle(18))),
              const SizedBox(height: 14),
              _pad(Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                pvAvatar(64),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(p.instructorName, style: pvTitleStyle(16)),
                    const SizedBox(height: 2),
                    Text(p.instructorRole, style: pvBody(kPurple, 12).copyWith(fontWeight: FontWeight.w600)),
                    if (p.instructorBio.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Text(p.instructorBio, style: pvBody(kSoft, 13).copyWith(height: 1.55)),
                    ],
                  ]),
                ),
              ])),

              // recorded-course lessons
              if (p.lessons.isNotEmpty) ...[
                _divider(),
                _pad(Text("What you'll learn", style: pvTitleStyle(17))),
                const SizedBox(height: 4),
                _pad(Text('Short lessons, in order - start anywhere.', style: pvBody(kMuted, 12.5))),
                const SizedBox(height: 12),
                _pad(Column(children: [
                  for (int i = 0; i < p.lessons.length; i++)
                    _lessonRow(context, p.lessons[i], accent: a, first: i == 0),
                ])),
              ],

              // live schedule
              if (p.isLive && (p.sessions.isNotEmpty || p.sessionTimes.isNotEmpty)) ...[
                _divider(),
                _pad(Text(p.isCohort ? 'Your schedule' : 'When it runs', style: pvTitleStyle(18))),
                if (p.sessionTimes.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  _pad(Row(children: [
                    const Icon(Icons.videocam_outlined, size: 15, color: kSoft),
                    const SizedBox(width: 7),
                    Expanded(child: Text(p.sessionTimes.join('  ·  '), style: pvBody(kSoft, 13))),
                  ])),
                ],
                const SizedBox(height: 14),
                for (final s in p.sessions) ...[_pad(_sessionCard(s, a)), const SizedBox(height: 12)],
              ],

              // what this covers
              if (p.covers.isNotEmpty) ...[
                _divider(),
                _pad(Text('What this covers', style: pvTitleStyle(18))),
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
                  decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(20)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    pvEyebrow("What's inside every cohort", color: kPurple),
                    const SizedBox(height: 14),
                    for (final t in p.takeaways)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          const Icon(Icons.check_rounded, size: 18, color: kPurple),
                          const SizedBox(width: 10),
                          Expanded(child: Text(t, style: pvBody(kInk, 14).copyWith(height: 1.5))),
                        ]),
                      ),
                  ]),
                )),
              ],

              // testimonial
              if (review != null) ...[
                const SizedBox(height: 26),
                _pad(Row(children: [
                  Text('★ ${p.rating}', style: pvBody(kCoral, 15).copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  Text(p.reviewsLabel, style: pvBody(kMuted, 13)),
                ])),
                const SizedBox(height: 12),
                _pad(Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                      color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: kHair)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Text('★★★★★', style: TextStyle(color: kCoral, fontSize: 13)),
                    const SizedBox(height: 10),
                    Text(review.quote, style: pvBody(kInk, 15).copyWith(height: 1.55)),
                    const SizedBox(height: 10),
                    Text.rich(TextSpan(children: [
                      TextSpan(text: '${review.who} ', style: const TextStyle(color: kInk, fontWeight: FontWeight.w700, fontSize: 13)),
                      TextSpan(text: '· ${review.when}', style: const TextStyle(color: kMuted, fontSize: 13)),
                    ])),
                  ]),
                )),
              ],

              const SizedBox(height: 20),
              _pad(Text('Led by a verified expert. ${p.priceNote[0].toUpperCase()}${p.priceNote.substring(1)}.',
                  textAlign: TextAlign.center, style: pvBody(kMuted, 12).copyWith(height: 1.55))),
            ],
          ),

          Positioned(left: 0, right: 0, bottom: 0, child: _ctaBar(context, cta)),
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
        child: Text(t, style: pvBody(filled ? Colors.white : a, 11).copyWith(fontWeight: FontWeight.w700)),
      );

  Widget _fact(String value, String label) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(value, style: pvTitleStyle(15), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(label, style: pvBody(kMuted, 11), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      );

  Widget _divider() => const Padding(
      padding: EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Divider(height: 1, color: Color(0xFFE4E2E5)));

  Widget _lessonRow(BuildContext context, PrepLesson l, {bool first = false, required Color accent}) =>
      GestureDetector(
        onTap: () => _play(context, l.title, subtitle: '${l.minutes} min'),
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14),
          decoration: BoxDecoration(border: Border(top: first ? BorderSide.none : const BorderSide(color: kHair))),
          child: Row(children: [
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: l.locked ? kPanel : accent.withValues(alpha: 0.12), shape: BoxShape.circle),
              child: Icon(l.locked ? Icons.lock_outline_rounded : Icons.play_arrow_rounded,
                  size: 17, color: l.locked ? kMuted : accent),
            ),
            const SizedBox(width: 13),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(l.title, style: pvBody(kInk, 14).copyWith(fontWeight: FontWeight.w600),
                    maxLines: 1, overflow: TextOverflow.ellipsis),
                const SizedBox(height: 2),
                Text(l.locked ? '${l.minutes} min · unlocks later, open anyway' : '${l.minutes} min',
                    style: pvBody(kMuted, 12)),
              ]),
            ),
            const Icon(Icons.chevron_right_rounded, size: 18, color: kMuted),
          ]),
        ),
      );

  Widget _sessionCard(PrepSession s, Color a) => Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(20)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            pvEyebrow(s.label, color: a),
            const Spacer(),
            if (s.when.isNotEmpty) ...[
              const Icon(Icons.schedule_rounded, size: 14, color: kSoft),
              const SizedBox(width: 5),
              Flexible(
                  child: Text(s.when,
                      textAlign: TextAlign.right,
                      style: pvBody(kSoft, 11).copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis)),
            ],
          ]),
          const SizedBox(height: 8),
          Text(s.title, style: pvTitleStyle(16)),
          if (s.points.isNotEmpty) const SizedBox(height: 10),
          for (final t in s.points)
            Padding(
              padding: const EdgeInsets.only(bottom: 7),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Container(
                    margin: const EdgeInsets.only(top: 7),
                    width: 5,
                    height: 5,
                    decoration: BoxDecoration(color: a, shape: BoxShape.circle)),
                const SizedBox(width: 11),
                Expanded(child: Text(t, style: pvBody(kInk, 13).copyWith(height: 1.5))),
              ]),
            ),
        ]),
      );

  Widget _coversRow(String t, {bool top = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 13),
        decoration: BoxDecoration(border: Border(top: top ? const BorderSide(color: kHair) : BorderSide.none)),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
              margin: const EdgeInsets.only(top: 7),
              width: 5,
              height: 5,
              decoration: const BoxDecoration(color: kPurple, shape: BoxShape.circle)),
          const SizedBox(width: 13),
          Expanded(child: Text(t, style: pvBody(kInk, 14).copyWith(height: 1.55))),
        ]),
      );

  Widget _ctaBar(BuildContext context, PrepCta cta) => AnimatedBuilder(
        animation: PrepareStore.instance,
        builder: (context, _) {
          final booked = PrepareStore.instance.isBooked(program.id);
          final showBooked = booked && !cta.watch;
          return Container(
            padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
            decoration: pvBottomFade,
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              if (cta.note != null && !showBooked)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(cta.note!,
                      textAlign: TextAlign.center,
                      style: pvBody(kSoft, 11).copyWith(fontWeight: FontWeight.w600),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis),
                ),
              Row(children: [
                Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(cta.watch ? 'Included' : program.price,
                      style: pvBody(kInk, 16).copyWith(fontWeight: FontWeight.w700)),
                  Text(cta.watch ? 'on ParentVeda+' : program.priceNote,
                      style: pvBody(kPurple, 11).copyWith(fontWeight: FontWeight.w600)),
                ]),
                const SizedBox(width: 14),
                Expanded(
                  child: SizedBox(
                    height: 52,
                    child: showBooked
                        ? Material(
                            color: kPanel,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => PrepareStore.instance.cancel(program.id),
                              child: Center(
                                child: Text('✓  Booked',
                                    style: GoogleFonts.manrope(
                                        fontSize: 15, fontWeight: FontWeight.w700, color: kPurple)),
                              ),
                            ),
                          )
                        : Material(
                            color: cta.enabled ? kPurple : kLockBg,
                            borderRadius: BorderRadius.circular(16),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(16),
                              onTap: () => _onCta(context, cta),
                              child: Center(
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  if (!cta.enabled) ...[
                                    const Icon(Icons.lock_outline_rounded, size: 16, color: kMuted),
                                    const SizedBox(width: 7),
                                  ],
                                  Flexible(
                                    child: Text(cta.label,
                                        style: GoogleFonts.manrope(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: cta.enabled ? Colors.white : kMuted),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis),
                                  ),
                                ]),
                              ),
                            ),
                          ),
                  ),
                ),
              ]),
            ]),
          );
        },
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

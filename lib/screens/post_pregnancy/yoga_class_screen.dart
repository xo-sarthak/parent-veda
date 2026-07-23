// =============================================================================
//  YogaClassScreen - a single class detail + booking (parenting · Yoga)
// -----------------------------------------------------------------------------
//  The class page: the instructor, rating & reviews, schedule/timing (for live),
//  session type, level, duration, price, an honest "about", things to know, and
//  real review snippets. A sticky CTA books (live) or starts (recorded) with a
//  mock confirmation sheet. Recorded classes show a striped video placeholder +
//  play (VIDEO ON HOLD - no real engine yet). Reached from the Yoga home.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_catalog.dart';
import 'booking_sheet.dart';
import 'pp_common.dart';
import 'pp_yoga_data.dart';
import 'yoga_common.dart';
import 'yoga_instructor_screen.dart';

class YogaClassScreen extends StatelessWidget {
  const YogaClassScreen({super.key, required this.cls});
  final YogaClass cls;

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  void _soon(BuildContext context, String m) => ScaffoldMessenger.of(context)
      .showSnackBar(SnackBar(content: Text(m), behavior: SnackBarBehavior.floating));

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: YogaStore.instance,
          builder: (context, _) {
            final store = YogaStore.instance;
            final saved = store.isSaved(cls.id);
            return Stack(children: [
              ListView(
                padding: const EdgeInsets.only(top: 12, bottom: 128),
                children: [
                  _pad(Row(children: [
                    Expanded(child: ppBack(context, cls.categoryInfo.title)),
                    GestureDetector(
                      onTap: () => store.toggleSave(cls.id),
                      behavior: HitTestBehavior.opaque,
                      child: Container(
                        width: 38,
                        height: 38,
                        alignment: Alignment.center,
                        decoration: const BoxDecoration(color: ppPanel, shape: BoxShape.circle),
                        child: Icon(saved ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                            size: 19, color: ppPurple),
                      ),
                    ),
                  ])),

                  // hero
                  const SizedBox(height: 16),
                  _pad(_hero(context)),

                  // title + mode + rating
                  const SizedBox(height: 20),
                  _pad(Row(children: [
                    yogaModeBadge(cls.mode),
                    const SizedBox(width: 10),
                    Flexible(
                      child: Text(cls.level.toUpperCase(),
                          style: ppBody(10.5, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.8),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis),
                    ),
                  ])),
                  const SizedBox(height: 12),
                  _pad(Text(cls.title, style: ppFraunces(30, h: 1.12))),
                  if (cls.tagline.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    _pad(Text(cls.tagline, style: ppBody(15))),
                  ],
                  const SizedBox(height: 12),
                  _pad(yogaStars(cls.rating, cls.reviewsCount)),

                  // instructor
                  const SizedBox(height: 20),
                  _pad(_instructorRow(context)),
                  const SizedBox(height: 14),
                  _pad(_instructorAbout(context)),

                  // quick facts
                  const SizedBox(height: 20),
                  _pad(_facts()),

                  // schedule / timing
                  const SizedBox(height: 24),
                  _pad(_scheduleCard()),

                  // about
                  const SizedBox(height: 28),
                  _pad(Text('About this class', style: ppJakarta(18))),
                  const SizedBox(height: 10),
                  _pad(Text(cls.about, style: ppBody(14.5, color: ppInk, h: 1.6))),

                  // good to know
                  const SizedBox(height: 26),
                  _pad(Text('Good to know', style: ppJakarta(18))),
                  const SizedBox(height: 12),
                  _pad(Column(children: [
                    for (final t in _goodToKnow()) _knowRow(t),
                  ])),

                  // reviews
                  const SizedBox(height: 28),
                  _pad(Row(children: [
                    Expanded(child: Text('What parents say', style: ppJakarta(18))),
                    yogaStars(cls.rating, cls.reviewsCount),
                  ])),
                  const SizedBox(height: 14),
                  _pad(Column(children: [
                    for (final r in cls.reviews) _reviewCard(r),
                  ])),

                  // guarantee
                  const SizedBox(height: 24),
                  _pad(ppEyebrow('The ParentVeda promise', color: ppBrown, spacing: 0.8)),
                  const SizedBox(height: 16),
                  _pad(ppGuaranteeRow()),

                  const SizedBox(height: 24),
                  _pad(Text('Please check with your doctor before starting any new movement in pregnancy or recovery.',
                      textAlign: TextAlign.center, style: ppBody(11.5, color: ppMuted, h: 1.5))),
                ],
              ),

              Positioned(left: 0, right: 0, bottom: 0, child: _ctaBar(context, store)),
            ]);
          },
        ),
      ),
    );
  }

  // ---- hero ---------------------------------------------------------------
  Widget _hero(BuildContext context) {
    final tint = yogaTint(cls.seed);
    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(children: [
        PpStriped(height: 210, colorA: tint.$1, colorB: tint.$2),
        if (cls.mode == YogaMode.recorded)
          Positioned.fill(
            child: GestureDetector(
              onTap: () => _soon(context, 'Playback coming soon'),
              behavior: HitTestBehavior.opaque,
              child: Center(child: yogaPlayDisc(58)),
            ),
          ),
        Positioned(
          left: 14,
          bottom: 14,
          child: yogaModeBadge(cls.mode),
        ),
        Positioned(
          right: 14,
          bottom: 14,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: ppInk.withValues(alpha: 0.55), borderRadius: BorderRadius.circular(999)),
            child: Text(cls.durationLabel, style: ppBody(11, color: Colors.white, w: FontWeight.w700)),
          ),
        ),
      ]),
    );
  }

  // ---- instructor ---------------------------------------------------------
  // Tappable now — opens the teacher's profile. For a class (and especially a
  // 1:1) you are booking the person, so being able to open who they are matters.
  Widget _instructorRow(BuildContext context) {
    final tint = yogaTint(cls.seed + 2);
    return GestureDetector(
      onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
          builder: (_) => YogaInstructorScreen(source: cls))),
      behavior: HitTestBehavior.opaque,
      child: Row(children: [
        Container(
          width: 54,
          height: 54,
          decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: ppBorder)),
          clipBehavior: Clip.antiAlias,
          child: PpStriped(height: 58, colorA: tint.$1, colorB: tint.$2),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(cls.instructorName, style: ppJakarta(16), maxLines: 1, overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text('${cls.instructorCredential}  ·  View profile',
                style: ppBody(12.5), maxLines: 2, overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: 10),
        const Icon(Icons.chevron_right_rounded, size: 22, color: ppPurple),
      ]),
    );
  }

  /// Who the trainer is, in enough depth to book them. For a one-to-one this
  /// matters more than the class description does - the session is only as
  /// good as the person running it.
  Widget _instructorAbout(BuildContext context) {
    final others = classesByInstructor(cls.instructorName, excludeId: cls.id);
    if (cls.instructorBio.isEmpty && others.isEmpty) return const SizedBox.shrink();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: ppBorder),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('About ${cls.instructorName}', style: ppJakarta(15.5)),
        if (cls.instructorBio.isNotEmpty) ...[
          const SizedBox(height: 9),
          Text(cls.instructorBio, style: ppBody(13.5, color: ppInk, h: 1.6)),
        ],
        if (cls.instructorFocus.isNotEmpty) ...[
          const SizedBox(height: 12),
          Text('WORKS MOST WITH',
              style: ppBody(9, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.7)),
          const SizedBox(height: 7),
          Wrap(spacing: 7, runSpacing: 7, children: [
            for (final f in cls.instructorFocus)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
                decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
                child: Text(f, style: ppBody(11.5, color: ppInk, w: FontWeight.w600)),
              ),
          ]),
        ],
        if (others.isNotEmpty) ...[
          const SizedBox(height: 14),
          Text('ALSO TEACHES',
              style: ppBody(9, color: ppMuted, w: FontWeight.w800).copyWith(letterSpacing: 0.7)),
          const SizedBox(height: 8),
          for (final o in others.take(3))
            GestureDetector(
              onTap: () => Navigator.of(context).pushReplacement(
                MaterialPageRoute<void>(builder: (_) => YogaClassScreen(cls: o)),
              ),
              behavior: HitTestBehavior.opaque,
              child: Padding(
                padding: const EdgeInsets.only(bottom: 9),
                child: Row(children: [
                  const Icon(Icons.self_improvement_rounded, size: 16, color: ppPurple),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(o.title,
                        style: ppBody(13, color: ppInk, w: FontWeight.w600),
                        maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  const Icon(Icons.chevron_right_rounded, size: 18, color: ppMuted),
                ]),
              ),
            ),
        ],
      ]),
    );
  }

  // ---- quick facts --------------------------------------------------------
  Widget _facts() => Row(children: [
        _fact(Icons.podcasts_outlined, 'Session', cls.modeLabel),
        const SizedBox(width: 10),
        _fact(Icons.timer_outlined, 'Length', cls.durationLabel),
        const SizedBox(width: 10),
        _fact(Icons.signal_cellular_alt_rounded, 'Level', cls.level),
      ]);

  Widget _fact(IconData icon, String label, String value) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(16)),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Icon(icon, size: 18, color: ppPurple),
            const SizedBox(height: 10),
            Text(label, style: ppBody(10.5, color: ppMuted, w: FontWeight.w700).copyWith(letterSpacing: 0.4)),
            const SizedBox(height: 2),
            Text(value, style: ppBody(13, color: ppInk, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
      );

  // ---- schedule / timing --------------------------------------------------
  Widget _scheduleCard() {
    final isLive = cls.isLive;
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), border: Border.all(color: ppHair)),
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 44,
          height: 44,
          alignment: Alignment.center,
          decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(14)),
          child: Icon(isLive ? Icons.event_available_outlined : Icons.play_circle_outline, size: 22, color: ppPurple),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text(isLive ? 'When it runs' : 'Watch anytime', style: ppJakarta(15)),
            const SizedBox(height: 4),
            Text(cls.schedule, style: ppBody(13, color: ppInk, h: 1.5)),
            const SizedBox(height: 4),
            Text(
                isLive
                    ? 'You will get a joining link and a reminder before it begins.'
                    : 'Practise as many times as you like, on any device.',
                style: ppBody(12, color: ppMuted, h: 1.5)),
          ]),
        ),
      ]),
    );
  }

  // ---- good to know -------------------------------------------------------
  List<String> _goodToKnow() {
    final out = <String>[];
    switch (cls.mode) {
      case YogaMode.liveOneToOne:
        out.add('A private, one-to-one session tailored entirely to you.');
        out.add('Pick a time that suits you - reschedule up to 12 hours before.');
      case YogaMode.liveGroup:
        out.add('A small live group, kept intimate so the teacher can guide you.');
        out.add('Can\'t make it live? The recording lands in your library.');
      case YogaMode.recorded:
        out.add('Fully recorded - start, pause and repeat whenever you like.');
        out.add('Yours to keep in your library for the whole journey.');
    }
    out.add('Every teacher is verified and specialises in the parenting journey.');
    out.add('Do only what feels right for your body - all postures are optional.');
    return out;
  }

  Widget _knowRow(String t) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Icon(Icons.check_rounded, size: 18, color: ppPurple),
          const SizedBox(width: 11),
          Expanded(child: Text(t, style: ppBody(14, color: ppInk, h: 1.5))),
        ]),
      );

  // ---- review card --------------------------------------------------------
  Widget _reviewCard(YogaReview r) => Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), border: Border.all(color: ppHair)),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(children: [
            for (int i = 0; i < 5; i++)
              Icon(i < r.stars ? Icons.star_rounded : Icons.star_border_rounded, size: 15, color: ppCoral),
          ]),
          const SizedBox(height: 10),
          Text(r.note, style: ppBody(14, color: ppInk, h: 1.55)),
          const SizedBox(height: 10),
          Text(r.author, style: ppBody(12.5, color: ppSoft, w: FontWeight.w700)),
        ]),
      );

  // ---- sticky CTA + confirmation ------------------------------------------
  // Split "₹399 / class · free on ParentVeda+" into the amount and the note so
  // both stay visible in the compact CTA bar.
  String get _priceAmount => cls.price.split('·').first.trim();
  String? get _priceNote {
    final parts = cls.price.split('·');
    return parts.length > 1 ? parts.sublist(1).join('·').trim() : null;
  }

  Widget _ctaBar(BuildContext context, YogaStore store) {
    final booked = store.isBooked(cls.id);
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
      decoration: const BoxDecoration(
        gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Color(0x00FBF9FE), ppBg], stops: [0, 0.22]),
      ),
      child: Row(children: [
        Flexible(
          child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
            // The price string bundles the amount and a note ("₹399 / class ·
            // free on ParentVeda+"); on one ellipsized line the note got cut, so
            // "free on ParentVeda+" was never visible. Split it across two lines.
            Text(_priceAmount, style: ppBody(15, color: ppInk, w: FontWeight.w800), maxLines: 1, overflow: TextOverflow.ellipsis),
            Text(_priceNote ?? (cls.isLive ? 'Cancel free · reschedule anytime' : 'Yours to keep, forever'),
                style: ppBody(11, color: ppPurple, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis),
          ]),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: GestureDetector(
            onTap: () => _confirm(context, store),
            behavior: HitTestBehavior.opaque,
            child: Container(
              height: 52,
              alignment: Alignment.center,
              decoration: BoxDecoration(color: booked ? ppInk : ppPurple, borderRadius: BorderRadius.circular(16)),
              child: Row(mainAxisSize: MainAxisSize.min, mainAxisAlignment: MainAxisAlignment.center, children: [
                if (booked) ...[
                  const Icon(Icons.check_rounded, size: 18, color: Colors.white),
                  const SizedBox(width: 7),
                ],
                Flexible(
                  child: Text(booked ? 'Booked' : cls.ctaLabel,
                      style: ppBody(15, color: Colors.white, w: FontWeight.w700), maxLines: 1, overflow: TextOverflow.ellipsis),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  void _confirm(BuildContext context, YogaStore store) {
    // If this class has been bridged to the booking engine, run the real
    // buy -> pick a slot -> booked flow. Otherwise fall back to the original
    // mock (a booked-id in YogaStore) until its offering exists.
    final offering = BookingCatalog.instance.offeringForCatalog(cls.id);
    if (offering != null) {
      showBookingSheet(context, offering);
      return;
    }
    store.book(cls.id);
    final isLive = cls.isLive;
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: Colors.white, borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
        child: SafeArea(
          top: false,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(99)))),
              const SizedBox(height: 20),
              Container(
                width: 54,
                height: 54,
                alignment: Alignment.center,
                decoration: BoxDecoration(color: ppPanel, shape: BoxShape.circle),
                child: const Icon(Icons.check_rounded, size: 28, color: ppPurple),
              ),
              const SizedBox(height: 16),
              Text(isLive ? "You're booked in" : 'Added to your practice', style: ppFraunces(24, h: 1.15)),
              const SizedBox(height: 8),
              Text(
                  isLive
                      ? '${cls.title} with ${cls.instructorName}. ${cls.schedule}. We\'ll send a reminder and a joining link before it starts.'
                      : '${cls.title} is now in your library. Start whenever you\'re ready, and come back to it as often as you like.',
                  style: ppBody(14, h: 1.6)),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () => Navigator.of(ctx).pop(),
                behavior: HitTestBehavior.opaque,
                child: Container(
                  height: 50,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: ppPurple, borderRadius: BorderRadius.circular(16)),
                  child: Text('Done', style: ppBody(15, color: Colors.white, w: FontWeight.w700)),
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}

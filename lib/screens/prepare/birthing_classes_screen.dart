// =============================================================================
//  BirthingClassesScreen (S5) - Prepare › Birthing Classes (interactive)
//  Class 1 is a free preview; enrolling (mock) unlocks classes 2–6. Every
//  unlocked class plays into the placeholder video screen.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/prepare_data.dart';
import '../../services/prepare_store.dart';
import 'prepare_common.dart';
import 'prepare_video_screen.dart';
import '../../localization/app_language.dart';

class BirthingClassesScreen extends StatelessWidget {
  const BirthingClassesScreen({super.key, required this.lang});

  final AppLanguage lang;

  static const String courseId = 'course_birthing';

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    void playClass(BirthingClass c) => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PrepareVideoScreen(
            lang: lang, title: c.title.now, subtitle: c.duration.now, blurb: c.blurb.now)));

    void enroll() => showPrepareBooking(
          context,
          lang: lang,
          id: courseId,
          title: s.uiCompleteBirthingCourse,
          priceLabel: '₹1,499 · ${s.prepFreeOnPlusShort}',
          whenLabel: s.prepBirthingWhen,
          heading: s.prepEnrollInCourse,
          cta: s.prepEnrollNow,
        );

    return Scaffold(
      backgroundColor: kCanvas,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: PrepareStore.instance,
          builder: (context, _) {
            final enrolled = PrepareStore.instance.isBooked(courseId);
            return ListView(
              padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
              children: [
                pvTopBar(context, lang: lang, backLabel: s.uiPrepare),
                const SizedBox(height: 22),
                pvEyebrow(s.prepEyebrowBigDay),
                const SizedBox(height: 10),
                Text(s.uiBirthingClasses, style: pvHeroStyle()),
                const SizedBox(height: 12),
                Text(s.uiEverythingBigDayTaught, style: pvSubStyle()),
                pvBanner(spans: [
                  pvText(s.uiRe),
                  pvBold(s.prepThirtyWeeksBold),
                  pvText(s.uiExactlyWhenMostMums),
                ]),

                // overview card
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(22),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: kBorder),
                    boxShadow: pvCardShadow,
                  ),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.uiCompleteBirthingCourse, style: pvTitleStyle(20)),
                    const SizedBox(height: 6),
                    Text(s.uiClassesSelfPacedVideo, style: pvBody(kSoft, 13)),
                    const SizedBox(height: 14),
                    Row(children: [
                      pvAvatar(34),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(children: [
                            // The instructor's name is a name - identical in
                            // both languages - so it leads in both, and the
                            // localized remainder carries the grammar. Hindi
                            // puts "ke saath" AFTER the name, so a leading
                            // "With " span would have had to translate to an
                            // empty string.
                            const TextSpan(
                                text: 'Meera Nair',
                                style: TextStyle(color: kInk, fontWeight: FontWeight.w700)),
                            TextSpan(text: s.prepCertifiedChildbirthEducator),
                            TextSpan(
                                text: s.prepObReviewed,
                                style: const TextStyle(color: kMuted)),
                          ]),
                          style: pvBody(kSoft, 13),
                        ),
                      ),
                    ]),
                    const SizedBox(height: 18),
                    const Divider(height: 1, color: Color(0xFFF0EBF5)),
                    const SizedBox(height: 16),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Flexible(
                        child: enrolled
                            ? Text.rich(
                                TextSpan(children: [
                                  TextSpan(
                                      text: s.prepEnrolledCheck,
                                      style: const TextStyle(color: kPurple, fontWeight: FontWeight.w700)),
                                ]),
                                style: pvBody(kInk, 14),
                              )
                            : Text.rich(
                                TextSpan(children: [
                                  const TextSpan(
                                      text: '₹1,499',
                                      style: TextStyle(color: kInk, fontWeight: FontWeight.w700)),
                                  TextSpan(
                                      text: s.prepFreeOn,
                                      style: const TextStyle(color: kMuted)),
                                  const TextSpan(
                                      text: 'ParentVeda+',
                                      style: TextStyle(color: kPurple, fontWeight: FontWeight.w700)),
                                ]),
                                style: pvBody(kInk, 14),
                              ),
                      ),
                      const SizedBox(width: 10),
                      pvPrimaryButton(enrolled ? s.prepStartWatching : s.prepFreePreview,
                          () => playClass(kBirthingClasses.first),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11)),
                    ]),
                  ]),
                ),

                const SizedBox(height: 28),
                Text(s.uiClasses, style: pvTitleStyle(16)),
                const SizedBox(height: 6),
                for (int i = 0; i < kBirthingClasses.length; i++)
                  _classRow(
                    s,
                    kBirthingClasses[i],
                    enrolled: enrolled,
                    bottom: i == kBirthingClasses.length - 1,
                    onPlay: () => playClass(kBirthingClasses[i]),
                    onEnroll: enroll,
                  ),

                if (!enrolled) ...[
                  const SizedBox(height: 18),
                  SizedBox(
                    width: double.infinity,
                    child: pvPrimaryButton(s.prepEnrollUnlockAll, enroll,
                        padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ],

                pvFooterNote(s.prepFooterBirthing),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _classRow(S s, BirthingClass c,
      {required bool enrolled, required bool bottom, required VoidCallback onPlay, required VoidCallback onEnroll}) {
    final unlocked = c.free || enrolled;
    return GestureDetector(
      onTap: unlocked ? onPlay : onEnroll,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 15),
        decoration: BoxDecoration(
          border: Border(
            top: const BorderSide(color: kHair),
            bottom: bottom ? const BorderSide(color: kHair) : BorderSide.none,
          ),
        ),
        child: Row(children: [
          SizedBox(
            width: 20,
            child: Text('${c.number}', style: pvTitleStyle(15).copyWith(color: unlocked ? kPurple : kMuted)),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(c.title.now, style: pvBody(kInk, 15).copyWith(fontWeight: FontWeight.w600, height: 1.3)),
              const SizedBox(height: 2),
              Text(c.duration.now, style: pvBody(kMuted, 12)),
            ]),
          ),
          const SizedBox(width: 10),
          if (c.free)
            pvPill(s.prepFreePreview)
          else if (enrolled)
            Container(
              width: 34,
              height: 34,
              alignment: Alignment.center,
              decoration: const BoxDecoration(color: kPanel, shape: BoxShape.circle),
              child: const Text('▸', style: TextStyle(color: kPurple, fontSize: 14)),
            )
          else
            const Icon(Icons.lock_outline_rounded, size: 16, color: Color(0xFFC7BBD6)),
        ]),
      ),
    );
  }
}

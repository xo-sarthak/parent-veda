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
import '../../widgets/pv_placeholders.dart';
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
          // Kept for revert: '₹1,499 · ${s.prepFreeOnPlusShort}' — the plus
          // membership does not exist yet, so it cannot be a price.
          priceLabel: '₹1,499',
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

                // ---- THE TRAILER, ABOVE EVERYTHING SHE HAS TO DECIDE ---------
                // ⚠️ THIS IS THE ONE PAID THING IN PREGNANCY WE ACTIVELY WANT
                // HER TO BUY, AND IT OPENED WITH A PRICE.
                //
                //   "Join a birth class section seems like unimportant, but for
                //    us it is most important, we want user to pay for it... the
                //    trailer should always be on top and free to watch."
                //
                // The ordering argument is the whole point and it is not a
                // preference: a page that leads with ₹1,499 asks her to decide
                // before she has seen anything, so the only information she has
                // when deciding is the number. A trailer first inverts that —
                // she knows what she is buying, and the price becomes the second
                // question instead of the first.
                //
                // ⚠️ FREE, AND NOT GATED BEHIND ENROLMENT. Note there is no
                // `enrolled` check on this: the trailer plays for everyone,
                // always. A locked trailer is a shop window with the shutter
                // down.
                const SizedBox(height: 20),
                PvVideoPlaceholder(
                  title: s.uiCompleteBirthingCourse,
                  subtitle: lang.isEnglish
                      ? 'Two minutes on what the six classes cover, and how '
                          'they are taught. Free to watch.'
                      : 'छह classes में क्या सिखाया जाता है, दो मिनट में। '
                          'देखना मुफ़्त।',
                  duration: lang.isEnglish ? '2 MIN · FREE' : '2 मिनट · मुफ़्त',
                  hue: 344,
                  slotId: 'course_birthing/trailer',
                  // Live: it opens the player. Only the FILE is pending, which
                  // is why this carries no coming-soon mark.
                  onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    settings: const RouteSettings(name: 'birthing/trailer'),
                    builder: (_) => PrepareVideoScreen(
                      lang: lang,
                      title: s.uiCompleteBirthingCourse,
                      subtitle: lang.isEnglish ? 'Trailer · 2 min' : 'ट्रेलर · 2 मिनट',
                      blurb: lang.isEnglish
                          ? 'A look at all six classes before you decide.'
                          : 'तय करने से पहले सभी छह classes की एक झलक।',
                    ),
                  )),
                ),

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
                            // ⚠️ THE "FREE ON PARENTVEDA+" HALF IS GONE. Kept
                            // for revert below.
                            //
                            //   "There is no ParentVeda Plus for now so delete
                            //    that from everywhere, comment it internally.
                            //    User will just pay separately."
                            //
                            // It was advertising a membership that cannot be
                            // bought, next to a price that can — so the cheaper
                            // option was the unbuyable one, which is the worst
                            // possible shape for a paywall. Every class is now
                            // simply paid for on its own.
                            //
                            //   TextSpan(text: s.prepFreeOn, ...),
                            //   TextSpan(text: 'ParentVeda+', ...),
                            : Text.rich(
                                TextSpan(children: [
                                  const TextSpan(
                                      text: '₹1,499',
                                      style: TextStyle(color: kInk, fontWeight: FontWeight.w700)),
                                  TextSpan(
                                      text: lang.isEnglish
                                          ? '  ·  one-time, yours for good'
                                          : '  ·  एक बार, हमेशा के लिए आपका',
                                      style: const TextStyle(color: kMuted)),
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

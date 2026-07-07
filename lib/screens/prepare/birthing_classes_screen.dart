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

class BirthingClassesScreen extends StatelessWidget {
  const BirthingClassesScreen({super.key});

  static const String courseId = 'course_birthing';

  @override
  Widget build(BuildContext context) {
    void playClass(BirthingClass c) => Navigator.of(context).push(MaterialPageRoute(
        builder: (_) => PrepareVideoScreen(title: c.title, subtitle: c.duration, blurb: c.blurb)));

    void enroll() => showPrepareBooking(
          context,
          id: courseId,
          title: 'Complete Birthing Course',
          priceLabel: '₹1,499 · free on ParentVeda+',
          whenLabel: '6 classes · self-paced + monthly live Q&A',
          heading: 'Enroll in this course',
          cta: 'Enroll now',
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
                pvTopBar(context, backLabel: 'Prepare'),
                const SizedBox(height: 22),
                pvEyebrow('For the big day'),
                const SizedBox(height: 10),
                Text('Birthing Classes', style: pvHeroStyle()),
                const SizedBox(height: 12),
                Text('Everything for the big day, taught by a childbirth educator.', style: pvSubStyle()),
                pvBanner(spans: [
                  pvText("You're "),
                  pvBold('30 weeks'),
                  pvText(' - exactly when most mums prepare for birth.'),
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
                    Text('Complete Birthing Course', style: pvTitleStyle(20)),
                    const SizedBox(height: 6),
                    Text('6 classes · self-paced video + a monthly live Q&A', style: pvBody(kSoft, 13)),
                    const SizedBox(height: 14),
                    Row(children: [
                      pvAvatar(34),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text.rich(
                          TextSpan(children: const [
                            TextSpan(text: 'With '),
                            TextSpan(
                                text: 'Meera Nair',
                                style: TextStyle(color: kInk, fontWeight: FontWeight.w700)),
                            TextSpan(text: ', certified childbirth educator '),
                            TextSpan(text: '(OB-reviewed)', style: TextStyle(color: kMuted)),
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
                                TextSpan(children: const [
                                  TextSpan(
                                      text: '✓ Enrolled',
                                      style: TextStyle(color: kPurple, fontWeight: FontWeight.w700)),
                                ]),
                                style: pvBody(kInk, 14),
                              )
                            : Text.rich(
                                TextSpan(children: const [
                                  TextSpan(
                                      text: '₹1,499',
                                      style: TextStyle(color: kInk, fontWeight: FontWeight.w700)),
                                  TextSpan(text: ' · free on ', style: TextStyle(color: kMuted)),
                                  TextSpan(
                                      text: 'ParentVeda+',
                                      style: TextStyle(color: kPurple, fontWeight: FontWeight.w700)),
                                ]),
                                style: pvBody(kInk, 14),
                              ),
                      ),
                      const SizedBox(width: 10),
                      pvPrimaryButton(enrolled ? 'Start watching' : 'Free preview',
                          () => playClass(kBirthingClasses.first),
                          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 11)),
                    ]),
                  ]),
                ),

                const SizedBox(height: 28),
                Text('The 6 classes', style: pvTitleStyle(16)),
                const SizedBox(height: 6),
                for (int i = 0; i < kBirthingClasses.length; i++)
                  _classRow(
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
                    child: pvPrimaryButton('Enroll - unlock all 6 classes', enroll,
                        padding: const EdgeInsets.symmetric(vertical: 15)),
                  ),
                ],

                pvFooterNote(
                    'Taught by a certified childbirth educator, reviewed by an OB. Watch at your pace, rewatch anytime, and bring questions to the live Q&A.'),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _classRow(BirthingClass c,
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
              Text(c.title, style: pvBody(kInk, 15).copyWith(fontWeight: FontWeight.w600, height: 1.3)),
              const SizedBox(height: 2),
              Text(c.duration, style: pvBody(kMuted, 12)),
            ]),
          ),
          const SizedBox(width: 10),
          if (c.free)
            pvPill('Free preview')
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

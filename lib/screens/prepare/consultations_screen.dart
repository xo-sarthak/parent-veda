// =============================================================================
//  ConsultationsScreen (S2) - Prepare › 1:1 Consultations (data-driven)
//  Every specialist opens their profile (S7).
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/prepare_data.dart';
import 'consultation_detail_screen.dart';
import 'prepare_common.dart';
import '../../localization/app_language.dart';

class ConsultationsScreen extends StatelessWidget {
  const ConsultationsScreen({super.key, required this.lang});

  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    void open(Specialist sp) => Navigator.of(context).push(
        MaterialPageRoute(builder: (_) => ConsultationDetailScreen(specialist: sp, lang: lang)));

    return Scaffold(
      backgroundColor: kCanvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            pvTopBar(context, lang: lang, backLabel: s.uiPrepare),
            const SizedBox(height: 22),
            pvEyebrow(s.prepEyebrowPrivate),
            const SizedBox(height: 10),
            Text(s.uiConsultations, style: pvHeroStyle()),
            const SizedBox(height: 12),
            Text(s.uiPrivateSessionRightExpert, style: pvSubStyle()),
            pvBanner(spans: [
              pvText(s.uiSomethingMindAfterWeek),
            ]),
            const SizedBox(height: 22),

            for (int i = 0; i < kSpecialists.length; i++)
              _specialist(s, kSpecialists[i], () => open(kSpecialists[i]),
                  bottom: i == kSpecialists.length - 1),

            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                pvEyebrow(s.prepHowItWorks, color: kPurple),
                const SizedBox(height: 8),
                Text(s.uiPickExpertPickSlot,
                    style: pvBody(kInk, 14).copyWith(height: 1.6)),
              ]),
            ),
            pvFooterNote(s.prepFooterConsultations),
          ],
        ),
      ),
    );
  }

  Widget _specialist(S str, Specialist s, VoidCallback onTap, {bool bottom = false}) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          border: Border(
            top: const BorderSide(color: kHair),
            bottom: bottom ? const BorderSide(color: kHair) : BorderSide.none,
          ),
        ),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 48,
            height: 48,
            alignment: Alignment.center,
            decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(16)),
            child: Icon(s.icon, size: 24, color: kPurple),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Expanded(child: Text(s.role.now, style: pvTitleStyle(16))),
                const SizedBox(width: 8),
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Text(s.fromPrice.now, style: pvBody(kSoft, 13)),
                ),
              ]),
              const SizedBox(height: 3),
              Text.rich(
                TextSpan(children: [
                  TextSpan(
                      text: s.name.now,
                      style: const TextStyle(color: kInk, fontWeight: FontWeight.w700, fontSize: 13)),
                  TextSpan(
                      text: '  ·  ${s.cred.now.split(' · ').first}',
                      style: const TextStyle(color: kMuted, fontSize: 13)),
                ]),
              ),
              const SizedBox(height: 2),
              Text(s.desc.now, style: pvBody(kSoft, 13)),
              const SizedBox(height: 8),
              Row(children: [
                Text(s.rating, style: pvBody(kCoral, 12).copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(width: 10),
                Text(str.uiHindiEnglish, style: pvBody(kMuted, 12)),
                if (s.next != null) ...[
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(s.next!.now,
                        style: pvBody(kPurple, 12).copyWith(fontWeight: FontWeight.w600),
                        overflow: TextOverflow.ellipsis),
                  ),
                ],
              ]),
            ]),
          ),
          const SizedBox(width: 10),
          Padding(
            padding: const EdgeInsets.only(top: 8),
            child: pvOutlineButton(str.prepBook, onTap),
          ),
        ]),
      ),
    );
  }
}

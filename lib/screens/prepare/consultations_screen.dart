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
  const ConsultationsScreen({super.key, required this.lang, this.onlyRole});

  final AppLanguage lang;

  /// ⚠️ THE FILTER, AND IT IS A GENERAL RULE RATHER THAN ONE SCREEN'S FEATURE.
  ///
  /// Review, stated as a rule: "whichever expert we are pointing to anywhere,
  /// if the user clicks it, that filter should be applied."
  ///
  /// The failure it fixes is small and corrosive. A card said "Have a
  /// gynaecologist go through it with you", she tapped it, and landed on a list
  /// of five specialists — gynae, nutritionist, lactation consultant,
  /// counsellor, sleep expert — with no gynae in sight until she scrolled and
  /// picked one herself. The app named the expert and then made her find them.
  /// That reads as the app not remembering what it just said.
  ///
  /// So: pass the specialist id you promised. Anything else stays reachable
  /// through "See all experts" — the filter narrows the view, it never removes
  /// a specialist from the app, which is the same personalisation line the rest
  /// of the app holds.
  final String? onlyRole;

  /// The specialists to show. Falls back to everyone when the requested role
  /// does not exist, rather than rendering an empty screen — a filter that
  /// matches nothing must never look like "we have no experts".
  List<Specialist> get _shown {
    if (onlyRole == null) return kSpecialists;
    final hit = kSpecialists.where((x) => x.id == onlyRole).toList();
    return hit.isEmpty ? kSpecialists : hit;
  }

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

            // Filtered when we promised a specific expert, everyone otherwise.
            for (int i = 0; i < _shown.length; i++)
              _specialist(s, _shown[i], () => open(_shown[i]),
                  bottom: i == _shown.length - 1),

            // ⚠️ THE WAY BACK OUT, and it is not optional. A filtered list that
            // cannot be widened is a list that has hidden things from her.
            if (onlyRole != null && _shown.length != kSpecialists.length) ...[
              const SizedBox(height: 6),
              InkWell(
                onTap: () => Navigator.of(context).push(MaterialPageRoute(
                    builder: (_) => ConsultationsScreen(lang: lang))),
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(color: kPurple.withValues(alpha: 0.35)),
                  ),
                  child: Text('See all experts',
                      style: pvBody(kPurple, 13.5)
                          .copyWith(fontWeight: FontWeight.w700)),
                ),
              ),
            ],

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

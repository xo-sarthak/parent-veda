// =============================================================================
//  MasterclassesScreen (S1) - Prepare › Masterclasses (data-driven)
//  Every card opens the real masterclass detail (S6).
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/prepare_data.dart';
import 'masterclass_detail_screen.dart';
import 'prepare_common.dart';
import '../../localization/app_language.dart';

class MasterclassesScreen extends StatelessWidget {
  const MasterclassesScreen({super.key, required this.lang});

  final AppLanguage lang;

  @override
  Widget build(BuildContext context) {
    final s = S(lang);
    final featured = kMasterclasses.firstWhere((m) => m.featured);
    final more = kMasterclasses.where((m) => !m.featured).toList();

    void open(Masterclass m) => Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => MasterclassDetailScreen(m: m, lang: lang)));

    return Scaffold(
      backgroundColor: kCanvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            pvTopBar(context, lang: lang, backLabel: s.uiPrepare),
            const SizedBox(height: 22),
            pvEyebrow(s.prepEyebrowLiveExpert),
            const SizedBox(height: 10),
            Text(s.uiMasterclasses, style: pvHeroStyle()),
            const SizedBox(height: 12),
            Text(s.uiDeepDiveLiveSessions, style: pvSubStyle()),
            pvBanner(spans: [
              pvText(s.uiRe),
              pvBold(s.prepThirtyWeeksBold),
              pvText(s.uiBirthMindStartHere),
            ]),

            // featured
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => open(featured),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: kBorder),
                  boxShadow: pvCardShadow,
                ),
                clipBehavior: Clip.antiAlias,
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Stack(children: [
                    const PvStriped(height: 170),
                    if (featured.badge != null)
                      Positioned(
                        top: 14,
                        left: 14,
                        child: pvPill(featured.badge!.now, bg: kCoral, fg: Colors.white),
                      ),
                  ]),
                  Container(
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    width: double.infinity,
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(featured.title.now, style: pvTitleStyle(20)),
                      const SizedBox(height: 10),
                      Text(featured.listDesc.now, style: pvBody(kSoft, 14)),
                      const SizedBox(height: 14),
                      Row(children: [
                        pvAvatar(36),
                        const SizedBox(width: 10),
                        Expanded(child: Text(_coachLine(s, featured), style: pvBody(kSoft, 13))),
                      ]),
                      const SizedBox(height: 18),
                      const Divider(height: 1, color: Color(0xFFF0EBF5)),
                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Text.rich(
                          TextSpan(children: [
                            TextSpan(
                                text: featured.price,
                                style: const TextStyle(color: kInk, fontWeight: FontWeight.w700)),
                            TextSpan(text: s.prepFreeOn, style: const TextStyle(color: kMuted)),
                            const TextSpan(
                                text: 'ParentVeda+',
                                style: TextStyle(color: kPurple, fontWeight: FontWeight.w700)),
                          ]),
                          style: pvBody(kInk, 14),
                        ),
                        pvPrimaryButton(s.uiReserveSeat, () => open(featured)),
                      ]),
                    ]),
                  ),
                ]),
              ),
            ),

            const SizedBox(height: 28),
            Text(s.uiMoreMasterclasses, style: pvTitleStyle(16)),
            const SizedBox(height: 6),
            for (int i = 0; i < more.length; i++)
              _row(s, more[i], () => open(more[i]), bottom: i == more.length - 1),

            pvFooterNote(s.prepFooterMasterclasses),
          ],
        ),
      ),
    );
  }

  String _coachLine(S s, Masterclass m) {
    if (m.coaches.isEmpty) return '';
    if (m.coaches.length == 1) return s.prepWithCoach('${m.coaches.first.name}');
    return s.prepWithCoaches(
        '${m.coaches[0].name}', m.coaches[1].name.now.split(' ').first);
  }

  Widget _row(S s, Masterclass m, VoidCallback onTap, {bool bottom = false}) {
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
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Expanded(child: Text(m.title.now, style: pvTitleStyle(16))),
            const SizedBox(width: 10),
            Text(m.price, style: pvBody(kInk, 14).copyWith(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 5),
          Text(m.listDesc.now, style: pvBody(kSoft, 13)),
          const SizedBox(height: 9),
          Row(children: [
            if (m.listChip != null) ...[
              pvPill(m.listChip!.now,
                  bg: chipBgFor(m.listChipIsCoral), fg: chipColorFor(m.listChipIsCoral)),
              const SizedBox(width: 8),
            ],
            Text(s.uiLiveRecording, style: pvBody(kMuted, 12)),
          ]),
        ]),
      ),
    );
  }
}

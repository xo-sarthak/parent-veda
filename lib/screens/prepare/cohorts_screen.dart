// =============================================================================
//  CohortsScreen (S3) — Prepare › Cohort Programs (data-driven)
//  Every program opens its cohort detail page.
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/prepare_data.dart';
import 'cohort_detail_screen.dart';
import 'prepare_common.dart';

class CohortsScreen extends StatelessWidget {
  const CohortsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final featured = kCohorts.firstWhere((c) => c.featured);
    final more = kCohorts.where((c) => !c.featured).toList();

    void open(Cohort c) =>
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => CohortDetailScreen(cohort: c)));

    return Scaffold(
      backgroundColor: kCanvas,
      body: SafeArea(
        bottom: false,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
          children: [
            pvTopBar(context, backLabel: 'Prepare'),
            const SizedBox(height: 22),
            pvEyebrow('Together, guided'),
            const SizedBox(height: 10),
            Text('Cohort Programs', style: pvHeroStyle()),
            const SizedBox(height: 12),
            Text('Small groups, a real coach, and mums due when you are.', style: pvSubStyle()),
            pvBanner(spans: [
              pvText("You're "),
              pvBold('30 weeks'),
              pvText(' — the Birth-Ready cohort starts Monday.'),
            ]),

            // featured cohort
            const SizedBox(height: 20),
            GestureDetector(
              onTap: () => open(featured),
              child: Container(
                padding: const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: kPanel,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: kBorder),
                ),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    if (featured.recommended != null)
                      pvPill(featured.recommended!, bg: Colors.white, fg: kPurple),
                    if (featured.seats != null) Text(featured.seats!, style: pvBody(kSoft, 11)),
                  ]),
                  const SizedBox(height: 14),
                  Text(featured.name, style: pvTitleStyle(22)),
                  const SizedBox(height: 6),
                  Text('${featured.duration} · ${featured.start ?? ''}'.trim(), style: pvBody(kSoft, 13)),
                  const SizedBox(height: 12),
                  Text(featured.desc, style: pvBody(kSoft, 14)),
                  const SizedBox(height: 14),
                  Row(children: [
                    pvAvatar(34),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text.rich(
                        TextSpan(children: [
                          pvText('with '),
                          TextSpan(
                              text: featured.coachName ?? 'your coach',
                              style: const TextStyle(color: kInk, fontWeight: FontWeight.w700)),
                          pvText(', childbirth educator'),
                        ]),
                        style: pvBody(kSoft, 13),
                      ),
                    ),
                  ]),
                  const SizedBox(height: 18),
                  const Divider(height: 1, color: Color(0xFFE1D7EC)),
                  const SizedBox(height: 16),
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Text(featured.price, style: pvBody(kInk, 14).copyWith(fontWeight: FontWeight.w700)),
                    pvPrimaryButton('Join the next cohort', () => open(featured)),
                  ]),
                ]),
              ),
            ),

            const SizedBox(height: 28),
            Text('More programs', style: pvTitleStyle(16)),
            const SizedBox(height: 6),
            for (int i = 0; i < more.length; i++)
              _row(more[i], () => open(more[i]), bottom: i == more.length - 1),

            const SizedBox(height: 22),
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18)),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                pvEyebrow("What's inside every cohort", color: kPurple),
                const SizedBox(height: 10),
                Text('Live sessions · a small peer group · weekly homework · a private WhatsApp group.',
                    style: pvBody(kInk, 14).copyWith(height: 1.7)),
                const SizedBox(height: 10),
                Text.rich(
                  TextSpan(children: [pvPurple('₹500 credit'), pvText(' for ParentVeda+.')]),
                  style: pvBody(kSoft, 13),
                ),
              ]),
            ),
            pvFooterNote('Small cohorts, real accountability — our most-loved way to prepare.'),
          ],
        ),
      ),
    );
  }

  Widget _row(Cohort c, VoidCallback onTap, {bool bottom = false}) {
    final meta = c.forWhen != null ? '${c.duration} · ${c.forWhen}' : c.duration;
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
            Expanded(child: Text(c.name, style: pvTitleStyle(16))),
            const SizedBox(width: 10),
            Text(c.price, style: pvBody(kInk, 14).copyWith(fontWeight: FontWeight.w700)),
          ]),
          const SizedBox(height: 5),
          Text(c.desc, style: pvBody(kSoft, 13)),
          const SizedBox(height: 8),
          Text(meta, style: pvBody(kMuted, 12)),
        ]),
      ),
    );
  }
}

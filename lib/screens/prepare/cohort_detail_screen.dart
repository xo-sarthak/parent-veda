// =============================================================================
//  CohortDetailScreen - Prepare › Cohort Program detail
//  Data-driven (any Cohort). Sticky CTA runs the mock join flow ("Enrolled").
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/prepare_data.dart';
import 'prepare_common.dart';

class CohortDetailScreen extends StatelessWidget {
  const CohortDetailScreen({super.key, required this.cohort});

  final Cohort cohort;

  @override
  Widget build(BuildContext context) {
    final c = cohort;
    return Scaffold(
      backgroundColor: kCanvas,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
            children: [
              pvTopBar(context, backLabel: 'Cohort Programs'),

              const SizedBox(height: 22),
              Row(children: [
                if (c.recommended != null) pvPill(c.recommended!),
                const Spacer(),
                if (c.seats != null) Text(c.seats!, style: pvBody(kSoft, 11)),
              ]),
              const SizedBox(height: 12),
              Text(c.name, style: pvHeroStyle().copyWith(fontSize: 30, height: 1.15)),
              const SizedBox(height: 12),
              Text(c.desc, style: pvSubStyle()),

              const SizedBox(height: 18),
              Row(children: [
                _fact(c.duration, 'programme'),
                const SizedBox(width: 10),
                _fact(c.start != null ? c.start!.replaceFirst('starts ', '') : (c.forWhen ?? 'Flexible'),
                    c.start != null ? 'start' : 'timing'),
                const SizedBox(width: 10),
                _fact('Live', '+ peer group'),
              ]),

              _divider(),
              _title("What's inside"),
              const SizedBox(height: 12),
              for (final w in c.whatsInside) _check(w),

              if (c.schedule.isNotEmpty) ...[
                _divider(),
                _title('The plan'),
                const SizedBox(height: 8),
                for (int i = 0; i < c.schedule.length; i++)
                  _weekRow(i + 1, c.schedule[i], bottom: i == c.schedule.length - 1),
              ],

              if (c.coachName != null) ...[
                _divider(),
                _title('Your coach'),
                const SizedBox(height: 14),
                Row(children: [
                  pvAvatar(56),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(c.coachName!, style: pvTitleStyle(15)),
                      const SizedBox(height: 2),
                      Text('Leads every live session and the group.',
                          style: pvBody(kSoft, 13).copyWith(height: 1.5)),
                    ]),
                  ),
                ]),
              ],

              if (c.reviews.isNotEmpty) ...[
                _divider(),
                _title('From mums who did it'),
                const SizedBox(height: 14),
                for (int i = 0; i < c.reviews.length; i++)
                  _review(c.reviews[i], bottom: i == c.reviews.length - 1),
              ],

              _divider(),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18)),
                child: Text.rich(
                  TextSpan(children: [
                    pvPurple('₹500 credit'),
                    pvText(' for ParentVeda+ members on any cohort.'),
                  ]),
                  style: pvBody(kInk, 14).copyWith(height: 1.5),
                ),
              ),
              pvFooterNote('Small cohorts, real accountability - our most-loved way to prepare.'),
            ],
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: PvStickyCta(
            id: c.id,
            price: c.price,
            note: c.duration,
            noteColor: kMuted,
            label: 'Join the next cohort',
            bookedLabel: 'Enrolled',
            onBook: () => showPrepareBooking(
              context,
              id: c.id,
              title: c.name,
              priceLabel: '${c.price} · ${c.duration}',
              whenLabel: c.start,
              heading: 'Join this cohort',
              cta: 'Join cohort',
            ),
          ),
        ),
      ]),
    );
  }

  Widget _fact(String big, String small) => Expanded(
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 6),
          decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(14)),
          child: Column(children: [
            Text(big,
                style: pvTitleStyle(13),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.ellipsis),
            const SizedBox(height: 2),
            Text(small, style: pvBody(kMuted, 11), textAlign: TextAlign.center),
          ]),
        ),
      );

  Widget _divider() => const Padding(
      padding: EdgeInsets.symmetric(vertical: 22), child: Divider(height: 1, color: Color(0xFFE4E2E5)));

  Widget _title(String t) => Text(t, style: pvTitleStyle(16));

  Widget _check(String text) => Padding(
        padding: const EdgeInsets.only(bottom: 11),
        child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Container(
            width: 18,
            height: 18,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: kPanel, shape: BoxShape.circle),
            child: const Text('✓', style: TextStyle(color: kPurple, fontSize: 11)),
          ),
          const SizedBox(width: 11),
          Expanded(child: Text(text, style: pvBody(kInk, 14).copyWith(height: 1.45))),
        ]),
      );

  Widget _weekRow(int n, String text, {bool bottom = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            border: Border(
          top: const BorderSide(color: kHair),
          bottom: bottom ? const BorderSide(color: kHair) : BorderSide.none,
        )),
        child: Row(children: [
          Container(
            width: 26,
            height: 26,
            alignment: Alignment.center,
            decoration: const BoxDecoration(color: kPanel, shape: BoxShape.circle),
            child: Text('$n', style: pvTitleStyle(13).copyWith(color: kPurple)),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(text, style: pvBody(kInk, 14).copyWith(height: 1.4))),
        ]),
      );

  Widget _review(Review r, {bool bottom = false}) => Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
            border: Border(
          top: const BorderSide(color: kHair),
          bottom: bottom ? const BorderSide(color: kHair) : BorderSide.none,
        )),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            Text.rich(TextSpan(children: [
              TextSpan(
                  text: r.who, style: const TextStyle(color: kInk, fontWeight: FontWeight.w700, fontSize: 14)),
              TextSpan(text: ' · ${r.when}', style: const TextStyle(color: kSoft, fontSize: 14)),
            ])),
            const Text('★★★★★', style: TextStyle(color: kCoral, fontSize: 13)),
          ]),
          const SizedBox(height: 8),
          Text(r.quote, style: pvBody(kSoft, 14).copyWith(height: 1.55)),
        ]),
      );
}

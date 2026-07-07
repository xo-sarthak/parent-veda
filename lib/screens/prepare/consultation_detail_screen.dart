// =============================================================================
//  ConsultationDetailScreen (S7) - Prepare › Consultation specialist profile
//  Data-driven (any Specialist). Time slots are selectable; the sticky CTA runs
//  the mock booking flow and reflects "Booked".
// =============================================================================

import 'package:flutter/material.dart';

import '../../data/prepare_data.dart';
import 'prepare_common.dart';

class ConsultationDetailScreen extends StatefulWidget {
  const ConsultationDetailScreen({super.key, required this.specialist});

  final Specialist specialist;

  @override
  State<ConsultationDetailScreen> createState() => _ConsultationDetailScreenState();
}

class _ConsultationDetailScreenState extends State<ConsultationDetailScreen> {
  int _slot = 0;

  @override
  Widget build(BuildContext context) {
    final s = widget.specialist;
    return Scaffold(
      backgroundColor: kCanvas,
      body: Stack(children: [
        SafeArea(
          bottom: false,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 100),
            children: [
              pvTopBar(context, backLabel: 'Consultations'),

              const SizedBox(height: 22),
              Row(children: [
                pvAvatar(78),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(s.name, style: pvTitleStyle(22)),
                    const SizedBox(height: 2),
                    Text('${s.role} · ${s.cred}',
                        style: pvBody(kPurple, 13).copyWith(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text(s.rating, style: pvBody(kCoral, 12).copyWith(fontWeight: FontWeight.w700)),
                      const SizedBox(width: 10),
                      Text('${s.reviews.length * 160} mothers', style: pvBody(kMuted, 12)),
                    ]),
                  ]),
                ),
              ]),
              const SizedBox(height: 16),
              Row(children: [
                _chip('Hindi'),
                const SizedBox(width: 8),
                _chip('English'),
                const SizedBox(width: 8),
                _chip('Video call'),
              ]),

              _divider(),
              _title('About ${s.name.split(' ').take(2).join(' ')}'),
              const SizedBox(height: 10),
              Text(s.about, style: pvBody(kSoft, 14).copyWith(height: 1.65)),

              _divider(),
              _title('She can help with'),
              const SizedBox(height: 12),
              for (final h in s.helps) _check(h),

              _divider(),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                _title('Choose a time'),
                Text('Today, 8 Jul', style: pvBody(kMuted, 12)),
              ]),
              const SizedBox(height: 12),
              SizedBox(
                height: 44,
                child: ListView(scrollDirection: Axis.horizontal, children: [
                  for (int i = 0; i < s.slots.length; i++) _slotChip(s.slots[i], i),
                ]),
              ),

              _divider(),
              _title("From mothers she's seen"),
              const SizedBox(height: 4),
              Text('Bedside manner, rated by mothers.', style: pvBody(kMuted, 12)),
              const SizedBox(height: 14),
              for (int i = 0; i < s.reviews.length; i++)
                _review(s.reviews[i], top: true, bottom: i == s.reviews.length - 1),

              _divider(),
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(18)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  pvEyebrow('How it works', color: kPurple),
                  const SizedBox(height: 8),
                  Text('Pick a slot → private video call → notes saved to your health record.',
                      style: pvBody(kInk, 14).copyWith(height: 1.6)),
                ]),
              ),
              pvFooterNote('Verified specialist. Transparent pricing, no surprises.'),
            ],
          ),
        ),

        Positioned(
          left: 0,
          right: 0,
          bottom: 0,
          child: PvStickyCta(
            id: s.id,
            price: s.consultPrice,
            note: '30-min call',
            noteColor: kMuted,
            label: 'Book for ${s.slots[_slot]}',
            bookedLabel: 'Booked',
            onBook: () => showPrepareBooking(
              context,
              id: s.id,
              title: '${s.role} · ${s.name}',
              priceLabel: '${s.consultPrice} · 30-min video call',
              whenLabel: 'Today, 8 Jul · ${s.slots[_slot]}',
              heading: 'Confirm your consult',
              cta: 'Confirm booking',
            ),
          ),
        ),
      ]),
    );
  }

  Widget _chip(String t) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(color: kPanel, borderRadius: BorderRadius.circular(999)),
        child: Text(t, style: pvBody(kSoft, 12).copyWith(fontWeight: FontWeight.w600)),
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

  Widget _slotChip(String label, int i) {
    final active = i == _slot;
    return GestureDetector(
      onTap: () => setState(() => _slot = i),
      child: Container(
        margin: const EdgeInsets.only(right: 10),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: active ? kPurple : Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: active ? null : Border.all(color: const Color(0xFFE4E2E5)),
        ),
        child: Text(label,
            style: pvBody(active ? Colors.white : kInk, 13)
                .copyWith(fontWeight: active ? FontWeight.w700 : FontWeight.w600)),
      ),
    );
  }

  Widget _review(Review r, {bool top = false, bool bottom = false}) => Container(
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

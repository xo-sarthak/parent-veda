// =============================================================================
//  VaxTimelineScreen — the full chronological journey (the backbone)
// -----------------------------------------------------------------------------
//  Every age visit, in order, as a story the parent is following — not a table.
//  Each node shows the age, the vaccines, a warm status, the Govt/IAP note, a
//  reminder indicator, and one educational insight ("why now"). Tapping a visit
//  opens its Learn-Why + After-Care detail. Timelines over tables; warm language.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_vaccine_data.dart';
import 'vax_detail_screen.dart';

const Color _green = Color(0xFF1F8A5B);
const Color _greenTint = Color(0xFFEAF4EE);

class VaxTimelineScreen extends StatelessWidget {
  const VaxTimelineScreen({super.key});

  Widget _pad(Widget c) => Padding(padding: const EdgeInsets.symmetric(horizontal: 24), child: c);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ppBg,
      body: AnimatedBuilder(
        animation: VaxStore.instance,
        builder: (context, _) {
          final store = VaxStore.instance;
          return ListView(
            padding: const EdgeInsets.only(top: 60, bottom: 40),
            children: [
              _pad(ppCircleBack(context, eyebrow: 'His vaccination journey')),
              const SizedBox(height: 22),
              _pad(Text('Every step, in order', style: ppFraunces(30, h: 1.12))),
              const SizedBox(height: 8),
              _pad(Text("From his first day to the toddler years — where he's been, what's due, and the calm road ahead.", style: ppBody(14, h: 1.55))),
              const SizedBox(height: 24),
              _pad(Column(children: [
                for (int i = 0; i < kVaxVisits.length; i++)
                  _visitNode(context, kVaxVisits[i], store, first: i == 0, last: i == kVaxVisits.length - 1),
              ])),
            ],
          );
        },
      ),
    );
  }

  Widget _visitNode(BuildContext context, VaxVisit v, VaxStore store, {bool first = false, bool last = false}) {
    final status = store.statusOf(v);
    return IntrinsicHeight(
      child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // connector + node
        SizedBox(
          width: 30,
          child: Column(children: [
            SizedBox(height: 4, child: first ? null : Container(width: 2, color: ppBorder)),
            _node(status),
            if (!last) Expanded(child: Container(width: 2, color: ppBorder)),
          ]),
        ),
        const SizedBox(width: 14),
        // card
        Expanded(
          child: GestureDetector(
            onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => VaxDetailScreen(visitId: v.id))),
            behavior: HitTestBehavior.opaque,
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: status == VaxStatus.due ? ppStripeB : Colors.white,
                borderRadius: BorderRadius.circular(18),
                border: Border.all(color: status == VaxStatus.due ? ppPurple : ppHair, width: status == VaxStatus.due ? 1.5 : 1),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: Text(v.ageLabel, style: ppJakarta(15))),
                  const SizedBox(width: 8),
                  _statusPill(status),
                ]),
                const SizedBox(height: 4),
                Text(v.date, style: ppBody(11.5, color: ppMuted)),
                const SizedBox(height: 12),
                Wrap(spacing: 7, runSpacing: 7, children: [for (final vax in v.vaccines) _vaxChip(vax.shortName)]),
                const SizedBox(height: 12),
                Row(children: [
                  Icon(v.govtFree ? Icons.verified_outlined : Icons.local_hospital_outlined, size: 14, color: v.govtFree ? _green : ppSoft),
                  const SizedBox(width: 6),
                  Flexible(child: Text(v.govtFree ? 'Free at a govt centre' : 'Private / IAP schedule', style: ppBody(11.5, color: ppSoft, w: FontWeight.w600), maxLines: 1, overflow: TextOverflow.ellipsis)),
                  const Spacer(),
                  if (store.hasReminder(v.id)) const Icon(Icons.notifications_active_rounded, size: 14, color: ppPurple),
                ]),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(12)),
                  child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    const Icon(Icons.lightbulb_outline, size: 14, color: ppPurple),
                    const SizedBox(width: 9),
                    Expanded(child: Text(v.insight, style: ppBody(12.5, color: ppInk, h: 1.5))),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ]),
    );
  }

  Widget _node(VaxStatus status) {
    switch (status) {
      case VaxStatus.done:
        return Container(width: 24, height: 24, alignment: Alignment.center, decoration: const BoxDecoration(color: _green, shape: BoxShape.circle), child: const Icon(Icons.check_rounded, size: 13, color: Colors.white));
      case VaxStatus.due:
        return Container(width: 28, height: 28, alignment: Alignment.center, decoration: BoxDecoration(shape: BoxShape.circle, color: ppCoralTint, border: Border.all(color: ppPurple, width: 2)), child: Container(width: 11, height: 11, decoration: const BoxDecoration(color: ppPurple, shape: BoxShape.circle)));
      case VaxStatus.upcoming:
        return Container(width: 24, height: 24, decoration: BoxDecoration(shape: BoxShape.circle, color: Colors.white, border: Border.all(color: const Color(0xFFC7BBD6), width: 2)));
    }
  }

  Widget _statusPill(VaxStatus status) {
    final (Color fg, Color bg) = switch (status) {
      VaxStatus.done => (_green, _greenTint),
      VaxStatus.due => (ppPurple, const Color(0xFFEDE6F5)),
      VaxStatus.upcoming => (ppSoft, ppPanel),
    };
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: bg, borderRadius: BorderRadius.circular(999)),
      child: Text(vaxStatusLabel(status), style: ppBody(10.5, color: fg, w: FontWeight.w700)),
    );
  }

  Widget _vaxChip(String label) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: ppLine)),
        child: Text(label, style: ppBody(11.5, color: ppInk, w: FontWeight.w600)),
      );
}

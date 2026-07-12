// =============================================================================
//  Provider booking sheet - mock, local-only "Book a consultation" flow
// -----------------------------------------------------------------------------
//  A bottom sheet opened from the expert profile CTA. Pick a day + a time slot
//  (derived from the expert's own timings), then confirm. Nothing is sent
//  anywhere - it's a local demo that ends in a friendly confirmation SnackBar.
// =============================================================================

import 'package:flutter/material.dart';

import 'pp_common.dart';
import 'pp_experts_data.dart';

/// Opens the mock booking sheet for [e]. Local only - no backend.
void showProviderBookingSheet(BuildContext context, Expert e) {
  showModalBottomSheet<void>(
    context: context,
    backgroundColor: Colors.transparent,
    isScrollControlled: true,
    builder: (_) => _BookingSheet(expert: e),
  );
}

class _BookingSheet extends StatefulWidget {
  const _BookingSheet({required this.expert});
  final Expert expert;

  @override
  State<_BookingSheet> createState() => _BookingSheetState();
}

class _BookingSheetState extends State<_BookingSheet> {
  int _day = 0;
  int _slot = -1;

  List<String> get _days =>
      widget.expert.availableToday ? const ['Today', 'Tomorrow', 'This weekend'] : const ['Tomorrow', 'This weekend'];

  // Time windows come straight from the expert's timings ("9-1 PM · 5-8 PM").
  // Falls back to gentle defaults when an expert has no timings set.
  List<String> get _slots {
    final raw = widget.expert.timings.trim();
    if (raw.isEmpty) return const ['Morning', 'Afternoon', 'Evening'];
    return raw
        .split('·')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  void _confirm() {
    final day = _days[_day];
    final slot = _slots[_slot];
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Requested: ${widget.expert.name}, $day · $slot. We\'ll confirm shortly.'),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final e = widget.expert;
    final ready = _slot >= 0;
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.fromLTRB(22, 14, 22, 24 + MediaQuery.of(context).viewInsets.bottom),
      child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
        Center(
          child: Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(color: ppLine, borderRadius: BorderRadius.circular(99)),
          ),
        ),
        const SizedBox(height: 18),
        Text('Book a consultation', style: ppFraunces(24, h: 1.1)),
        const SizedBox(height: 4),
        Text('${e.name} · ${e.credential}',
            style: ppBody(13), maxLines: 2, overflow: TextOverflow.ellipsis),

        if (e.timings.trim().isNotEmpty || e.videoConsult) ...[
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: [
            _pill(e.availableToday ? 'Available today' : 'Next available tomorrow',
                icon: Icons.schedule_rounded),
            if (e.videoConsult) _pill('Video consult', icon: Icons.videocam_outlined),
          ]),
        ],

        const SizedBox(height: 22),
        Text('Choose a day', style: ppJakarta(15)),
        const SizedBox(height: 10),
        Wrap(spacing: 9, runSpacing: 9, children: [
          for (var i = 0; i < _days.length; i++)
            _choice(_days[i], _day == i, () => setState(() => _day = i)),
        ]),

        const SizedBox(height: 20),
        Text('Choose a time', style: ppJakarta(15)),
        const SizedBox(height: 10),
        Wrap(spacing: 9, runSpacing: 9, children: [
          for (var i = 0; i < _slots.length; i++)
            _choice(_slots[i], _slot == i, () => setState(() => _slot = i)),
        ]),

        const SizedBox(height: 24),
        GestureDetector(
          onTap: ready ? _confirm : null,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 52,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: ready ? ppPurple : ppLine,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              ready ? 'Confirm booking · ${e.ctaPrice}' : 'Pick a time to continue',
              style: ppBody(15, color: ready ? Colors.white : ppMuted, w: FontWeight.w700),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ),
        const SizedBox(height: 12),
        Text('Mock booking - saved on this device only. No payment is taken.',
            textAlign: TextAlign.center, style: ppBody(11.5, color: ppMuted, h: 1.5)),
      ]),
    );
  }

  Widget _pill(String label, {required IconData icon}) => Container(
        padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
        decoration: BoxDecoration(color: ppPanel, borderRadius: BorderRadius.circular(999)),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Icon(icon, size: 13, color: ppPurple),
          const SizedBox(width: 6),
          Text(label, style: ppBody(12, color: ppInk, w: FontWeight.w600)),
        ]),
      );

  Widget _choice(String label, bool on, VoidCallback onTap) => GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 11),
          decoration: BoxDecoration(
            color: on ? ppPurple : Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: on ? ppPurple : ppBorder),
          ),
          child: Text(label,
              style: ppBody(13.5, color: on ? Colors.white : ppInk, w: FontWeight.w700)),
        ),
      );
}

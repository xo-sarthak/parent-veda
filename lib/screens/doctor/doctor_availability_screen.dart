// =============================================================================
//  DoctorAvailabilityScreen — pick the times parents can book you
// -----------------------------------------------------------------------------
//  A weekday x time-of-day grid the doctor taps to mark themselves free. The
//  same shape Practo/cult use: choose your recurring windows, and those become
//  the slots parents see. Persists locally for now (DoctorAvailability); the
//  backend piece turns these into real booking_slots.
// =============================================================================

import 'package:flutter/material.dart';

import '../../doctor/doctor_availability.dart';
import '../../doctor/doctor_session.dart';
import '../post_pregnancy/pp_common.dart';

class DoctorAvailabilityScreen extends StatefulWidget {
  const DoctorAvailabilityScreen({super.key});

  @override
  State<DoctorAvailabilityScreen> createState() =>
      _DoctorAvailabilityScreenState();
}

class _DoctorAvailabilityScreenState extends State<DoctorAvailabilityScreen> {
  static const _days = [
    (DateTime.monday, 'Mon'),
    (DateTime.tuesday, 'Tue'),
    (DateTime.wednesday, 'Wed'),
    (DateTime.thursday, 'Thu'),
    (DateTime.friday, 'Fri'),
    (DateTime.saturday, 'Sat'),
    (DateTime.sunday, 'Sun'),
  ];

  // A tidy set of bookable times of day.
  static const _times = [
    (9, 0, '9:00 AM'),
    (11, 0, '11:00 AM'),
    (14, 0, '2:00 PM'),
    (17, 0, '5:00 PM'),
    (18, 30, '6:30 PM'),
    (20, 0, '8:00 PM'),
  ];

  @override
  void initState() {
    super.initState();
    DoctorAvailability.instance.init();
    DoctorAvailability.instance.syncFromServer();
  }

  @override
  Widget build(BuildContext context) {
    final expertId = DoctorSession.instance.expertId ?? '';
    return Scaffold(
      backgroundColor: ppBg,
      body: SafeArea(
        bottom: false,
        child: AnimatedBuilder(
          animation: DoctorAvailability.instance,
          builder: (context, _) {
            final avail = DoctorAvailability.instance;
            return ListView(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 40),
              children: [
                ppBack(context, 'Dashboard'),
                const SizedBox(height: 16),
                ppEyebrow('Availability', color: ppPurple),
                const SizedBox(height: 8),
                Text('When can parents book you?',
                    style: ppFraunces(26, h: 1.1)),
                const SizedBox(height: 6),
                Text(
                    'Tap the times you are free each week. ${avail.count(expertId)} selected.',
                    style: ppBody(13.5, color: ppSoft, h: 1.5)),
                const SizedBox(height: 22),
                for (final t in _times) ...[
                  Text(t.$3,
                      style: ppBody(12.5, color: ppMuted, w: FontWeight.w800)
                          .copyWith(letterSpacing: 0.5)),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      for (final d in _days) ...[
                        Expanded(child: _cell(expertId, d.$1, t.$1, t.$2, d.$2)),
                        if (d != _days.last) const SizedBox(width: 6),
                      ],
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                      color: ppPanel, borderRadius: BorderRadius.circular(12)),
                  child: Text(
                      'Saved automatically. These become the slots parents can '
                      'book — the backend sync goes live with the next update.',
                      style: ppBody(12, color: ppSoft, h: 1.45)),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _cell(String expertId, int weekday, int hour, int minute, String label) {
    final w = AvailWindow(weekday, hour, minute);
    final on = DoctorAvailability.instance.isOn(expertId, w);
    return GestureDetector(
      onTap: () => DoctorAvailability.instance.toggle(expertId, w),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: on ? ppPurple : Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: on ? ppPurple : ppHair),
        ),
        child: Text(label,
            style: ppBody(11,
                color: on ? Colors.white : ppSoft,
                w: on ? FontWeight.w700 : FontWeight.w600)),
      ),
    );
  }
}

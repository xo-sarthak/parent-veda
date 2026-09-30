// =============================================================================
//  TTC home - "Visit today at 10:30am · 2 questions to ask" (2026-09-28)
// -----------------------------------------------------------------------------
//  One small card on HER home, only on the day of a visit, opening that
//  visit's page (where the questions carry their ticks). The user approved it
//  with the rest of "a question belongs to a visit": the questions are only
//  useful if they are in front of her on the day, and the home is what she
//  opens on the day.
//
//  ⚠️ NOTHING ON ANY OTHER DAY. No "next visit in 4 days" filler: a card that
//  is always there stops being read. With no visit today this draws nothing
//  and takes no space (the home's no-repetition sweep pumps days without a
//  visit and must not see it).
//
//  ⚠️ TODAY, NOT THE STRIP'S DAY. The home's sheet follows the day chosen on
//  the strip; this card, like the round's notice above it, is about today.
//
//  Shape: the round's notice card is the home's one-line "about you, today"
//  slot, and this is a quieter row in the same place: an icon, the visit said
//  by name and time, the count under it, a chevron.
// =============================================================================

import 'package:flutter/material.dart';

import '../../booking/booking_store.dart';
import '../../theme/pv_fonts.dart';
import '../../ttc/ttc_doctor_questions_store.dart';
import '../../ttc/ttc_records_store.dart';
import '../v2/v2_palette.dart';
import 'ttc_appointments_screen.dart';

/// The visit today, soonest first, or null. The couple's own visits and
/// ParentVeda bookings, the same list the Appointments page shows.
TtcApptEntry? ttcVisitToday({DateTime? now}) {
  final n = now ?? DateTime.now();
  for (final e in ttcApptEntries()) {
    final l = e.startsLocal;
    if (l.year == n.year && l.month == n.month && l.day == n.day) return e;
  }
  return null;
}

class TtcVisitTodayCard extends StatelessWidget {
  const TtcVisitTodayCard({super.key});

  @override
  Widget build(BuildContext context) => ListenableBuilder(
        // Its own listener, so ticking a question on the visit's page and
        // coming back shows the new count without the home rebuilding.
        listenable: Listenable.merge([
          TtcAppointmentsStore.instance,
          BookingStore.instance,
          TtcDoctorQuestionsStore.instance,
          V2PaletteStore.instance,
        ]),
        builder: (context, _) {
          final e = ttcVisitToday();
          if (e == null) return const SizedBox.shrink();
          final p = V2PaletteStore.instance.current;
          final n = TtcDoctorQuestionsStore.instance.openCountFor(e.visitId);
          final title = '${e.title} today at ${ttcApptTime(e.startsLocal)}';
          // Named for what the tap does when there is nothing to count yet.
          final sub = n > 0
              ? ttcQuestionsToAsk(n)
              : 'No questions saved. Open the visit to add one.';
          return Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child: Semantics(
              button: true,
              label: '$title. $sub',
              excludeSemantics: true,
              child: Material(
                color: p.surface,
                borderRadius: BorderRadius.circular(18),
                child: InkWell(
                  key: const ValueKey('ttc_home_visit_today'),
                  borderRadius: BorderRadius.circular(18),
                  onTap: () => openTtcAppointment(context, e),
                  child: Container(
                    padding: const EdgeInsets.fromLTRB(14, 13, 10, 13),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: p.line),
                    ),
                    child: Row(children: [
                      Icon(Icons.event_available_outlined,
                          size: 21, color: p.ink1),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(title,
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                  style: pvManrope(
                                      fontSize: 14.5,
                                      fontWeight: FontWeight.w800,
                                      color: p.ink1)),
                              const SizedBox(height: 2),
                              Text(sub,
                                  style: pvManrope(
                                      fontSize: 12.5,
                                      height: 1.4,
                                      color: p.ink2)),
                            ]),
                      ),
                      Icon(Icons.chevron_right_rounded,
                          size: 20, color: p.ink3),
                    ]),
                  ),
                ),
              ),
            ),
          );
        },
      );
}

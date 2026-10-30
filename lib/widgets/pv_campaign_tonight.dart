// =============================================================================
//  PvCampaignTonight - tonight's campaign, in Messages
// -----------------------------------------------------------------------------
//  Phase 6b, B5 (2026-10-30). docs/NOTIFICATIONS-6B-PLAN.md, "As built: B5".
//
//  When the server books a campaign for her evening, that evening's own
//  message goes to Messages without ringing (`push_bookings.dart`). So the
//  campaign belongs in Messages too: one row at the top of each stage's
//  Messages screen, from 19:00 on its evening (when the push goes) or as soon
//  as it is sent, until the day ends. A tap opens its page through the one
//  opener, as the push itself does.
//
//  Nothing booked: nothing drawn. This is a message, not a section, so there
//  is no empty state to advertise; the stage's own list carries that.
// =============================================================================

import 'package:flutter/material.dart';

import '../screens/doors/pv_list_row.dart';
import '../screens/v2/v2_palette.dart';
import '../services/family_phone_plan.dart' show kPushCampaignHour;
import '../services/notification_service.dart';
import '../services/push_bookings.dart';
import 'pv_toast.dart';

/// Whether [b] shows in Messages at [now]: sent, or its 19:00 has come. Pure.
bool pvCampaignShowsNow(PushBooking b, DateTime now) =>
    b.status == 'sent' ||
    !now.isBefore(DateTime(b.day.year, b.day.month, b.day.day, kPushCampaignHour));

class PvCampaignTonight extends StatelessWidget {
  const PvCampaignTonight({
    super.key,
    required this.p,
    this.padding = const EdgeInsets.fromLTRB(20, 0, 20, 18),
    this.now,
  });

  final V2Palette p;

  /// Around the row. TTC's list already has its gutter, so it passes less.
  final EdgeInsets padding;

  /// Test seam: the time to judge "tonight" by.
  final DateTime? now;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PushBookings.instance,
      builder: (context, _) {
        final t = now ?? DateTime.now();
        final b = PushBookings.instance.tonight(now: t);
        if (b == null || !pvCampaignShowsNow(b, t)) return const SizedBox.shrink();
        final link = b.link;
        return Padding(
          padding: padding,
          child: PvRowGroup(p: p, children: [
            PvListRow(
              key: ValueKey('pv_campaign_${b.rowId}'),
              p: p,
              leading: PvMarkWell(
                  p: p, hue: 28, size: 44, icon: Icons.campaign_outlined),
              title: b.title ?? '',
              line: b.body,
              lineMaxLines: 3,
              meta: 'Tonight',
              onTap: () {
                if (link != null) {
                  NotificationService.instance.openLink(link);
                } else {
                  // No silent tap: say why and what to do.
                  pvToast(context,
                      "This one has nothing more to open. It's here so you can read it again.");
                }
              },
            ),
          ]),
        );
      },
    );
  }
}

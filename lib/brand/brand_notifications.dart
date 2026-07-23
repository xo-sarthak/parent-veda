// =============================================================================
//  BrandNotifications — Brand Product 15, the sponsored notification
// -----------------------------------------------------------------------------
//  The most restrained placement in the whole system, and it is built to look
//  restrained. A sponsored notification is PUSHED — it arrives on a parent's
//  phone without being asked for — so every guard in the Brand Studio applies
//  at once, plus one this slot alone needs: a global minimum gap between ANY
//  two sponsored notifications, so a parent is never peppered even if several
//  campaigns are eligible.
//
//  THE FREQUENCY, and why it is a constant you can change:
//    A real sponsor's terms decide how often they may notify. We do not have
//    those terms yet, so the gap is a single named placeholder —
//    kSponsoredNotificationMinGapDays. Change that one number when a real deal
//    sets it. Per-campaign maxImpressions caps how many times ONE campaign may
//    fire; this gap caps how close together ANY two may land.
//
//  WHAT IT WILL NOT DO:
//    * fire for a parent the campaign does not target (audience is enforced)
//    * fire twice for the same campaign past its cap
//    * fire before the gap since the last sponsored notification has elapsed
//    * fire silently — the body always says who it is from
//    * ever be the reason a screen breaks: every call is best-effort.
// =============================================================================

import '../services/notification_service.dart';
import 'brand_context.dart';
import 'brand_models.dart';
import 'brand_store.dart';
import 'brand_studio.dart';

/// The minimum days between any two sponsored notifications. A PLACEHOLDER — a
/// real sponsor's terms will set the true number; changing it is this one line.
/// Deliberately generous: over-restraint is the safe error for a trusted app.
const int kSponsoredNotificationMinGapDays = 14;

class BrandNotifications {
  BrandNotifications._();
  static final BrandNotifications instance = BrandNotifications._();

  /// Consider sending a sponsored notification. Call at a natural moment — app
  /// open on the parenting side is the obvious one. Returns the campaign that
  /// was sent, or null (the overwhelmingly common answer — sending nothing is
  /// the system working correctly, not a failure).
  Future<BrandCampaign?> maybeSend({
    required BrandStage stage,
    DateTime? now,
  }) async {
    try {
      final at = now ?? DateTime.now();

      // Global gap first — cheapest check, and the one that protects the parent
      // regardless of how many campaigns happen to be eligible.
      final last = BrandStudioStore.instance.lastNotificationAt;
      if (last != null && at.difference(last).inDays < kSponsoredNotificationMinGapDays) {
        return null;
      }

      // Then the ordinary resolver: targeting, schedule, per-campaign cap, the
      // kill switch — all enforced here, exactly as every other slot.
      final ctx = captureBrandContext(stage: stage, now: at);
      final campaign = BrandStudio.instance.resolve(BrandSlot.sponsoredNotification, ctx);
      if (campaign == null) return null;

      final title = campaign.creative.headline;
      final body = _bodyWithDisclosure(campaign);

      await NotificationService.instance.showNow(title: title, body: body);

      // Spend the per-campaign cap AND start the global gap. Order matters: if
      // showNow threw we would not reach here, and would not have claimed an
      // impression for a notification that never landed.
      BrandStudioStore.instance.recordImpression(campaign.id);
      BrandStudioStore.instance.markNotificationSent(at);
      return campaign;
    } catch (_) {
      // A sponsored notification is never worth a broken session.
      return null;
    }
  }

  /// The body always names the sponsor. A parent must be able to tell in one
  /// glance that this is a brand talking, not ParentVeda — that honesty is the
  /// whole permission to be in the notification tray at all.
  String _bodyWithDisclosure(BrandCampaign c) {
    final line = c.creative.subline.isNotEmpty ? c.creative.subline : c.creative.story;
    return '$line\n\nFrom ${c.brand.name}';
  }
}

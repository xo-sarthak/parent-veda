// =============================================================================
//  BrandSampling — the claim actually leaves the phone
// -----------------------------------------------------------------------------
//  The sampling screen collected a postal address, took an explicit consent
//  tick, promised "ParentVeda posts it", and then threw the address away.
//  markCompleted() wrote a local flag and that was the whole of it. A parent
//  saw a confirmation for a parcel nobody could ever send.
//
//  So the ONE rule this file exists to enforce:
//
//      the confirmation is shown only if the claim was actually saved.
//
//  Every other brand write in this codebase is fire-and-forget
//  (`.catchError((_) {})`), because losing an impression count costs nothing.
//  This one is not, and must never be made so. A silently dropped analytics
//  row is a gap in a chart; a silently dropped claim is a promise broken to a
//  person who is now waiting by the door.
//
//  Hence: it returns a result, it distinguishes "already claimed" from
//  "failed", and the screen is expected to act on that rather than assume.
// =============================================================================

// The map literal below keeps `if (feedback != null)` rather than the
// null-aware element form: the VALUE is nullable, not the key, and the
// analyzer's suggestion does not apply to a conditional entry.
// ignore_for_file: use_null_aware_elements

import '../services/remote/supabase_repo.dart';

enum SampleClaimResult {
  /// Saved. The parcel is now somebody's job.
  ok,

  /// This parent already claimed this campaign — the unique constraint fired.
  /// Not an error: the confirmation is still the honest thing to show.
  alreadyClaimed,

  /// Not signed in. Nothing was saved, and nothing should be confirmed.
  notSignedIn,

  /// Offline, or the server refused. Nothing was saved.
  failed,
}

class BrandSampling {
  BrandSampling._();

  static const _table = 'brand_sample_claims';

  /// Save a claim. Awaited on purpose — see the header.
  static Future<SampleClaimResult> claim({
    required String campaignId,
    required String address,
  }) async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return SampleClaimResult.notSignedIn;

    final trimmed = address.trim();
    if (trimmed.isEmpty) return SampleClaimResult.failed;

    try {
      // insert() attaches user_id itself and THROWS rather than swallowing,
      // which is what makes the duplicate case below detectable at all.
      await SupabaseRepo.insert(_table, {
        'campaign_id': campaignId,
        'address': trimmed,
      });
      return SampleClaimResult.ok;
    } catch (e) {
      // 23505 = unique_violation: one claim per campaign per parent, enforced
      // in the database because two quick taps are the ordinary way a finite
      // stock of samples gets double-claimed.
      if (e.toString().contains('23505')) {
        return SampleClaimResult.alreadyClaimed;
      }
      return SampleClaimResult.failed;
    }
  }

  /// Attach the post-parcel rating. Best-effort, and correctly so: feedback is
  /// a nice-to-have, and losing it costs a parent nothing.
  static Future<void> rate({
    required String campaignId,
    required int rating,
    String? feedback,
  }) async {
    final uid = SupabaseRepo.userId;
    if (uid == null) return;
    try {
      await SupabaseRepo.updateMatch(
        _table,
        {'campaign_id': campaignId, 'user_id': uid},
        {'rating': rating, if (feedback != null) 'feedback': feedback},
      );
    } catch (_) {/* best-effort */}
  }

  /// How many parents have claimed a campaign. Counts only — this is the one
  /// number a brand is ever given, and it is safe to show a parent too.
  static Future<int> claimedCount(String campaignId) async {
    try {
      final rows = await SupabaseRepo.callFunction(
          'brand_sample_counts', {'p_campaign_id': campaignId});
      final first = rows.whereType<Map>().firstOrNull;
      return (first?['claimed'] as num?)?.toInt() ?? 0;
    } catch (_) {
      return 0;
    }
  }
}

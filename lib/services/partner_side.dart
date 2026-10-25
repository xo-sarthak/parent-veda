// =============================================================================
//  Whose row answers "which stage" on this phone (STAGE-TRANSITIONS R2,
//  2026-10-25)
// -----------------------------------------------------------------------------
//  His phone read HIS OWN profile row for her stage and for "the pregnancy has
//  ended", so after her birth, her loss or her move to trying his app went on
//  showing the pregnancy he paired into. Two facts that are hers by nature,
//  read from the wrong person.
//
//  ⚠️ NO MIGRATION. 0009's policy "view own or partner profile" already lets a
//  paired partner SELECT her row; nothing on his side ever asked. This is a
//  client change: on his phone, while paired, her row answers, and his phone
//  never writes either fact (they are hers to change).
//
//  ⚠️ PAIRING IS SYMMETRIC, THE RULE IS NOT. Both rows carry `partner_id`, so
//  "paired" alone would make her phone follow HIS stale row. The rule needs
//  the role: the phone set up as the father follows; the mother's never does.
//
//  ⚠️ HER ROW UNREADABLE IS NOT "UNPAIRED". Offline, or a failed read, returns
//  no row and the stores keep what they hold. Falling back to his own row
//  there would put his stale stage back, which is the bug this fixes.
// =============================================================================

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../screens/auth/auth_flow_screen.dart' show kUserRoleKey;
import 'remote/supabase_repo.dart';

/// Pure: does this phone take her row's word? The father's phone, paired.
@visibleForTesting
bool followsPartnerFor({required String? role, required String? partnerId}) =>
    role == 'father' && partnerId != null && partnerId.isNotEmpty;

class PartnerSide {
  PartnerSide._();

  /// What the last read decided, so a push can skip without asking the
  /// network again. False until a read has said otherwise.
  static bool following = false;

  /// Test seam: the partner lookup and the two row reads.
  @visibleForTesting
  static Future<String?> Function() partnerIdOf = SupabaseRepo.myPartnerId;
  @visibleForTesting
  static Future<Map<String, dynamic>?> Function(String id, String columns) rowOf =
      SupabaseRepo.fetchProfileOf;
  @visibleForTesting
  static Future<Map<String, dynamic>?> Function(String columns) ownRow =
      SupabaseRepo.fetchMyProfile;

  /// [columns] from the row whose word holds on this phone: hers on his
  /// paired phone, else this person's own. `hers` says which, so a store
  /// knows not to write the fact back.
  static Future<({bool hers, Map<String, dynamic>? row})> readStageRow(String columns) async {
    String? role;
    try {
      role = (await SharedPreferences.getInstance()).getString(kUserRoleKey);
    } catch (_) {/* read as hers: not the father */}
    if (role != 'father') {
      following = false;
      return (hers: false, row: await ownRow(columns));
    }
    final partner = await partnerIdOf();
    if (!followsPartnerFor(role: role, partnerId: partner)) {
      following = false;
      return (hers: false, row: await ownRow(columns));
    }
    following = true;
    return (hers: true, row: await rowOf(partner!, columns));
  }

  @visibleForTesting
  static void resetForTest() {
    following = false;
    partnerIdOf = SupabaseRepo.myPartnerId;
    rowOf = SupabaseRepo.fetchProfileOf;
    ownRow = SupabaseRepo.fetchMyProfile;
  }
}

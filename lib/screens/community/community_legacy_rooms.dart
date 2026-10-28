// =============================================================================
//  Old room ids -> the rooms the new community actually has (2026-10-28)
// -----------------------------------------------------------------------------
//  The three superseded community UIs (pregnancy `community_screen.dart`,
//  parenting `post_pregnancy/community_screen.dart`, TTC
//  `ttc_community_screen.dart`) each named rooms from the seed list in
//  `lib/data/community_data.dart`. Links into those rooms still live in data
//  (a door's `pp_community/potty`, You, Maa's `pp_community/mothers_4th_trimester`),
//  and the new community's rooms are server rows (0121_community.sql) with
//  their own ids. This is the one place an old id is translated.
//
//  WHY A TABLE AND NOT A PASS-THROUGH. An id the server does not have would
//  open the new room screen on a room that does not exist. Mapping to the
//  nearest real room keeps the intent of the link ("other parents dealing with
//  potty training"); an id with no honest neighbour maps to null, and the
//  caller opens the community home instead, which is never wrong.
// =============================================================================

/// Room ids that exist on the server (0121_community.sql). Kept in step with
/// the migration by hand; a new server room needs adding here only if an old
/// link should land on it.
const Set<String> kCommunityServerRooms = {
  'ttc_naturally', 'ttc_two_week_wait', 'ttc_pcos', 'ttc_ivf', 'ttc_loss',
  'ttc_emotional', 'preg_first_trimester', 'second_tri', 'preg_third_trimester',
  'high_risk', 'preg_nutrition', 'working_moms', 'mothers_4th_trimester',
  'feeding', 'baby_sleep', 'first_foods', 'milestones', 'toddlers', 'potty',
  'working_parents', 'anything',
};

/// Old seed id -> nearest server room. Ids already on the server pass through.
const Map<String, String> _kLegacyRoom = {
  // Trying to conceive
  'ttc_first_month': 'ttc_naturally',
  'ttc_ask_doctor': 'ttc_naturally',
  'ttc_iui': 'ttc_ivf',
  'ttc_endo': 'ttc_pcos',
  'ttc_nutrition': 'ttc_naturally',
  // Pregnancy
  'nov2026': 'preg_first_trimester',
  'first_time': 'preg_first_trimester',
  'breastfeeding_prep': 'feeding',
  'twin_preg': 'high_risk',
  'ivf': 'high_risk',
  'preg_fitness': 'preg_nutrition',
  // Parenting
  'infants_0_1': 'baby_sleep',
  'ones': 'toddlers',
  'twos': 'toddlers',
  'threes': 'toddlers',
};

/// The server room for an old room id, or null when there is no honest
/// neighbour (open the community home then).
String? communityRoomForLegacy(String? oldId) {
  if (oldId == null || oldId.isEmpty) return null;
  if (kCommunityServerRooms.contains(oldId)) return oldId;
  return _kLegacyRoom[oldId];
}

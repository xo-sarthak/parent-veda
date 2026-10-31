// =============================================================================
//  PushWire - every call the phone makes to Supabase for push, in one place
// -----------------------------------------------------------------------------
//  Phase 6b, B2 (2026-10-30). Four functions in 0140, and nothing else: the
//  phone never writes push_devices, push_consent or push_audience directly
//  (none of them grants insert or update). Each builder below returns the
//  exact parameter map one function takes, and the callers only use these.
//
//  ⚠️ WHY THE BUILDERS EXIST. Supabase ignores nothing here: a parameter name
//  that does not match the SQL makes the call fail, and the token, consent
//  and audience writes all swallow their errors (a cloud failure is never a
//  crash). A renamed `p_` key would fail silently on every phone. So the
//  names live in one file and test/push_b2_contract_test.dart compares each
//  builder's keys to the function's real signature in the migration.
//
//  The stage words are profiles.life_stage's, so the server joins consent to
//  the profile with a plain equality.
//
//  B5 (2026-10-30, 0146): two more. `pv_push_tapped` fills tapped_at on her
//  own booking (the phone has no update grant on push_sends), and one READ,
//  [bookingsSelect]: her own push_sends rows with their campaign's text, which
//  RLS lets her see once a campaign is booked for her (0143).
// =============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import 'remote/supabase_repo.dart';

class PushWire {
  PushWire._();

  static const register = 'pv_push_register';
  static const unregister = 'pv_push_unregister';
  static const consent = 'pv_push_consent';
  static const audience = 'pv_push_audience';
  static const tapped = 'pv_push_tapped';

  /// B5: the table she reads her bookings from, and the columns, with the
  /// campaign's text embedded through the campaign_id foreign key.
  static const bookingsTable = 'push_sends';
  static const bookingsSelect =
      'id, send_on, status, push_campaigns(kind, title, body, link_kind, link_id)';

  /// The statuses that hold an evening: still to go, or gone. A `skipped`
  /// booking (cancelled, past the cutoff, no device) gives the evening back;
  /// a `failed` one never reached her.
  static const bookingsHolding = ['queued', 'sent'];

  /// The push data's queue name for campaign bookings. Only these taps are
  /// recorded; a `push_tests` tap is you checking the text.
  static const queueBookings = 'push_sends';

  /// push_consent.stage, the same three words as profiles.life_stage.
  static const stageTrying = 'trying';
  static const stagePregnancy = 'pregnancy';
  static const stageParenting = 'parenting';

  /// push_consent.source: which control she answered with.
  static const sourceCard = 'messages_card';
  static const sourceSwitch = 'messages_switch';

  static Map<String, dynamic> registerParams({
    required String deviceId,
    required String token,
    required String platform,
    required int linkVersion,
  }) => {
    'p_device_id': deviceId,
    'p_token': token,
    'p_platform': platform,
    'p_link_version': linkVersion,
  };

  static Map<String, dynamic> unregisterParams(String deviceId) => {
    'p_device_id': deviceId,
  };

  static Map<String, dynamic> consentParams({
    required String stage,
    required bool granted,
    required String source,
    required DateTime decidedAt,
  }) => {
    'p_stage': stage,
    'p_granted': granted,
    'p_source': source,
    'p_decided_at': decidedAt.toUtc().toIso8601String(),
  };

  /// [quietEvenings] (6b leftover L3, 0151): the IST evenings in the next
  /// 14 days the phone calls quiet. Dates only; the reason stays here.
  static Map<String, dynamic> audienceParams({
    required List<DateTime> busyEvenings,
    required bool quiet,
    required List<DateTime> quietEvenings,
  }) => {
    'p_busy_evenings': [for (final d in busyEvenings) dateKey(d)],
    'p_quiet': quiet,
    'p_quiet_evenings': [for (final d in quietEvenings) dateKey(d)],
  };

  static Map<String, dynamic> tappedParams(String rowId) => {
    'p_row_id': rowId,
  };

  /// A calendar date as Postgres reads a `date`.
  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  // ---- the server's calendar is India's (6b leftover L2, 2026-10-31) -------
  //
  // push_sends.send_on and push_audience.busy_evenings are IST dates, and
  // the campaign goes at 19:00 IST. A phone set to another zone has another
  // calendar: 23:00 in London on the 31st is 04:30 on the 1st in India, a
  // MORNING there. So every date or hour the phone compares with the
  // server's is read in India, not in the phone's own zone. On an Indian
  // phone the two are the same, which is why B5 got away with local dates.
  //
  // A fixed offset, not a time-zone database: India has had no summer time
  // since 1945, and pulling in tz data for one zone that never moves would
  // be weight with no answer it changes.

  static const Duration istOffset = Duration(hours: 5, minutes: 30);

  /// [at]'s wall clock in India. The fields read IST; the value is UTC-flagged,
  /// so compare its fields, never the instant.
  static DateTime ist(DateTime at) => at.toUtc().add(istOffset);

  /// [at]'s calendar day in India, as a local date at midnight: the shape the
  /// phone's sets of days already use, and what [dateKey] writes.
  static DateTime istDay(DateTime at) {
    final i = ist(at);
    return DateTime(i.year, i.month, i.day);
  }

  /// [at]'s hour in India.
  static int istHour(DateTime at) => ist(at).hour;

  /// The instant [hour]:00 IST on India's [day], as a phone (local) time.
  static DateTime istTime(DateTime day, int hour) =>
      DateTime.utc(day.year, day.month, day.day, hour).subtract(istOffset).toLocal();

  /// Who is signed in, or null. Null when Supabase never started, which is
  /// the logged-out shape. Swapped in tests (not @visibleForTesting: the
  /// three push classes call it).
  static String? Function() userId = () => SupabaseRepo.userId;

  /// Calls one function and returns its answer. Throws on failure; each
  /// caller decides how hard to try. Swapped in tests.
  static Future<dynamic> Function(String fn, Map<String, dynamic> params) call =
      (fn, params) => Supabase.instance.client.rpc(fn, params: params);

  /// B5: her bookings from [fromDay] on that still hold an evening. RLS
  /// returns only her own rows. Throws on failure. Swapped in tests.
  static Future<List<Map<String, dynamic>>> Function(String fromDay) bookings =
      (fromDay) async {
        final rows = await Supabase.instance.client
            .from(bookingsTable)
            .select(bookingsSelect)
            .gte('send_on', fromDay)
            .inFilter('status', bookingsHolding);
        return [for (final r in rows) Map<String, dynamic>.from(r)];
      };
}

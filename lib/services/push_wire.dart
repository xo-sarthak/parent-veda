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
// =============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';

import 'remote/supabase_repo.dart';

class PushWire {
  PushWire._();

  static const register = 'pv_push_register';
  static const unregister = 'pv_push_unregister';
  static const consent = 'pv_push_consent';
  static const audience = 'pv_push_audience';

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

  static Map<String, dynamic> audienceParams({
    required List<DateTime> busyEvenings,
    required bool quiet,
  }) => {
    'p_busy_evenings': [for (final d in busyEvenings) dateKey(d)],
    'p_quiet': quiet,
  };

  /// A calendar date as Postgres reads a `date`.
  static String dateKey(DateTime d) =>
      '${d.year.toString().padLeft(4, '0')}-'
      '${d.month.toString().padLeft(2, '0')}-'
      '${d.day.toString().padLeft(2, '0')}';

  /// Who is signed in, or null. Null when Supabase never started, which is
  /// the logged-out shape. Swapped in tests (not @visibleForTesting: the
  /// three push classes call it).
  static String? Function() userId = () => SupabaseRepo.userId;

  /// Calls one function and returns its answer. Throws on failure; each
  /// caller decides how hard to try. Swapped in tests.
  static Future<dynamic> Function(String fn, Map<String, dynamic> params) call =
      (fn, params) => Supabase.instance.client.rpc(fn, params: params);
}

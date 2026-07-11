// =============================================================================
//  WhatsAppPrefs  -  read/write the WhatsApp opt-in fields on `profiles`
// -----------------------------------------------------------------------------
//  Shared by BOTH entry points so they stay in sync (B2):
//    * onboarding (auth_flow_screen)  -> source 'onboarding'
//    * Profile tab card               -> source 'profile_screen'
//  Both write the same columns added in migration 0015 (phone, wa_opt_in,
//  wa_marketing_opt_in, wa_consent_at, wa_consent_source, language). The
//  server-side engine reads these to decide who to message.
// =============================================================================

import 'package:supabase_flutter/supabase_flutter.dart';

class WhatsAppPrefs {
  final String? phone;
  final bool optIn;

  const WhatsAppPrefs({this.phone, this.optIn = false});

  /// Normalise a typed number to E.164 (the format WhatsApp requires).
  /// India-first: a bare 10-digit number becomes +91XXXXXXXXXX. Returns null
  /// for empty/garbage so we never store a broken number.
  static String? normalizePhone(String? raw) {
    if (raw == null) return null;
    final t = raw.trim();
    if (t.isEmpty) return null;
    final hasPlus = t.startsWith('+');
    final digits = t.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return null;
    if (hasPlus) return '+$digits';
    if (digits.length == 10) return '+91$digits'; // bare Indian mobile
    if (digits.length == 12 && digits.startsWith('91')) return '+$digits';
    return '+$digits'; // assume they typed a country code
  }

  /// The set of `profiles` columns to write for a given opt-in state. Pure (no
  /// I/O) so the onboarding flow can MERGE it into its existing profile update
  /// (one write) instead of issuing a second one.
  static Map<String, dynamic> fieldsFor({
    required bool optIn,
    String? phone,
    String? language, // 'en' | 'hi'
    required String source, // 'onboarding' | 'profile_screen'
  }) {
    final data = <String, dynamic>{
      'wa_opt_in': optIn,
      'phone': normalizePhone(phone),
    };
    if (optIn) {
      // The weekly guide is a Marketing-category template, so opting in to it
      // is also a marketing consent. Stamp when + where they consented (DPDP).
      data['wa_marketing_opt_in'] = true;
      data['wa_consent_at'] = DateTime.now().toUtc().toIso8601String();
      data['wa_consent_source'] = source;
    }
    if (language != null && language.isNotEmpty) data['language'] = language;
    return data;
  }

  /// Write the opt-in fields to the current user's profile row.
  /// Returns false if not signed in or the write failed.
  static Future<bool> save({
    required bool optIn,
    String? phone,
    String? language,
    required String source,
  }) async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return false;
    try {
      await client
          .from('profiles')
          .update(fieldsFor(
              optIn: optIn, phone: phone, language: language, source: source))
          .eq('id', uid);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Read the current opt-in + phone for the signed-in user (for the Profile
  /// card to reflect whatever was set at onboarding, and vice versa).
  static Future<WhatsAppPrefs> load() async {
    final client = Supabase.instance.client;
    final uid = client.auth.currentUser?.id;
    if (uid == null) return const WhatsAppPrefs();
    try {
      final row = await client
          .from('profiles')
          .select('phone, wa_opt_in')
          .eq('id', uid)
          .maybeSingle();
      if (row == null) return const WhatsAppPrefs();
      return WhatsAppPrefs(
        phone: row['phone'] as String?,
        optIn: (row['wa_opt_in'] as bool?) ?? false,
      );
    } catch (_) {
      return const WhatsAppPrefs();
    }
  }
}

// =============================================================================
//  EntitlementStore — what this user may do, and who is paying for it.
// -----------------------------------------------------------------------------
//  The app's half of the capability architecture (migration 0057).
//
//  THE ONE RULE THAT MATTERS: this store decides what to SHOW, never what to
//  ALLOW. Every capability that actually protects something is enforced again
//  server-side — by an RLS policy or a security-definer function calling
//  has_capability(). So a modified client gains a button that does not work,
//  rather than access it should not have.
//
//  That is the same separation as everywhere else in this codebase: Directus's
//  permission screens are a convenience layer and Postgres grants are the
//  boundary; a `verdict` in the app is a rendering hint and the database is the
//  authority. If you ever find yourself relying on this store to keep something
//  safe, the capability needs a policy, not a better client check.
//
//  Local-first like every other store. A parent on a train sees the benefit
//  they had yesterday rather than a spinner or, worse, a locked screen.
// =============================================================================

import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Capability ids. Kept as constants rather than an enum because the registry
/// lives in the database and can grow without a release — an unknown id from
/// the server is simply a capability this build does not gate on yet, which is
/// the whole point of the architecture.
class Caps {
  const Caps._();
  static const consultationCredit = 'consultation_credit';
  static const sponsorEvents = 'sponsor_events';
  static const sponsorResources = 'sponsor_resources';
  static const sponsorAnnouncements = 'sponsor_announcements';
  static const masterclassAccess = 'masterclass_access';

  /// Reveals the Programme section — take-up of the benefit an organisation
  /// sponsors. Granted by its OWN plan (0060), never by `employer_standard`:
  /// bundling it with the employee plan would show every colleague the
  /// roster. It is the one capability here that is about other people.
  static const sponsorAdmin = 'sponsor_admin';
}

/// The sponsor behind a user's benefit, when there is one.
@immutable
class SponsorInfo {
  const SponsorInfo({
    required this.id,
    required this.name,
    this.kind = 'employer',
    this.logoUrl,
    this.supportContact,
    this.activatedAt,
  });

  final String id;
  final String name;
  final String kind;
  final String? logoUrl;
  final String? supportContact;
  final DateTime? activatedAt;

  static SponsorInfo? fromMap(Map<String, dynamic>? m) {
    if (m == null || m['sponsor_id'] == null) return null;
    return SponsorInfo(
      id: m['sponsor_id'] as String,
      name: (m['name'] as String?) ?? '',
      kind: (m['kind'] as String?) ?? 'employer',
      logoUrl: m['logo_url'] as String?,
      supportContact: m['support_contact'] as String?,
      activatedAt: m['activated_at'] == null
          ? null
          : DateTime.tryParse(m['activated_at'].toString()),
    );
  }

  Map<String, dynamic> toMap() => {
        'sponsor_id': id,
        'name': name,
        'kind': kind,
        'logo_url': logoUrl,
        'support_contact': supportContact,
        'activated_at': activatedAt?.toIso8601String(),
      };
}

class EntitlementStore extends ChangeNotifier {
  EntitlementStore._();
  static final EntitlementStore instance = EntitlementStore._();

  static const _cacheKey = 'entitlements_v1';

  Set<String> _capabilities = const {};
  SponsorInfo? _sponsor;
  bool _loaded = false;

  /// Everything this user currently holds.
  Set<String> get capabilities => Set.unmodifiable(_capabilities);

  /// The organisation providing the benefit, or null for an ordinary user.
  SponsorInfo? get sponsor => _sponsor;

  bool get isSponsored => _sponsor != null;

  /// Whether to SHOW a capability-gated affordance. Never a security decision —
  /// see the header.
  bool can(String capability) => _capabilities.contains(capability);

  void ensureLoaded() {
    if (_loaded) return;
    _loaded = true;
    _load();
  }

  Future<void> refresh() => _fetch();

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString(_cacheKey);
      if (raw != null) {
        final m = jsonDecode(raw) as Map<String, dynamic>;
        _capabilities = ((m['caps'] as List?) ?? const [])
            .map((e) => e.toString())
            .toSet();
        _sponsor = SponsorInfo.fromMap(
            (m['sponsor'] as Map?)?.cast<String, dynamic>());
        notifyListeners();
      }
    } catch (_) {/* a corrupt cache is not worth surfacing */}
    await _fetch();
  }

  Future<void> _fetch() async {
    // Supabase.instance THROWS when the backend was never initialised — in
    // tests, and on a build with no keys. CLAUDE.md: "an uninitialised backend
    // must behave exactly like being logged out", so this is caught here rather
    // than allowed to escape an async call nobody is awaiting.
    final SupabaseClient client;
    try {
      client = Supabase.instance.client;
    } catch (_) {
      return;
    }

    if (client.auth.currentUser == null) {
      // Signed out behaves exactly like an uninitialised backend: no
      // capabilities, no sponsor, no crash.
      if (_capabilities.isNotEmpty || _sponsor != null) {
        _capabilities = const {};
        _sponsor = null;
        notifyListeners();
      }
      return;
    }

    try {
      final caps = await client.rpc('my_capabilities');
      final sponsorRow = await client.rpc('my_sponsor');

      _capabilities = (caps as List? ?? const [])
          .map((e) => e.toString())
          .toSet();
      _sponsor = SponsorInfo.fromMap(
          (sponsorRow as Map?)?.cast<String, dynamic>());
      notifyListeners();
      await _persist();
    } catch (_) {
      // Offline, or the migration has not been run. Keep whatever was
      // cached — never downgrade someone's benefit because a request failed.
    }
  }

  Future<void> _persist() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(
        _cacheKey,
        jsonEncode({
          'caps': _capabilities.toList(),
          'sponsor': _sponsor?.toMap(),
        }),
      );
    } catch (_) {/* best effort */}
  }

  // ---- activation ----------------------------------------------------------

  /// Ask for a one-time code to be sent to [workEmail].
  ///
  /// Returns the server's `{ok, code, message}` verbatim. The UI shows
  /// `message`; it should branch on `code`, never on the wording.
  Future<Map<String, dynamic>> requestActivation(String workEmail) =>
      _call('request_sponsor_activation', {'p_work_email': workEmail});

  /// Verify the code and, if it is right, unlock the benefit.
  Future<Map<String, dynamic>> confirmActivation(
          String workEmail, String code) =>
      _call('confirm_sponsor_activation',
          {'p_work_email': workEmail, 'p_code': code});

  Future<Map<String, dynamic>> _call(
      String fn, Map<String, dynamic> args) async {
    try {
      final res = await Supabase.instance.client.rpc(fn, params: args);
      final map = (res as Map?)?.cast<String, dynamic>() ??
          <String, dynamic>{'ok': false, 'code': 'unexpected_response'};
      if (map['ok'] == true) await refresh();
      return map;
    } catch (e) {
      // A network failure is not a refusal, and must not read like one — the
      // difference between "your code was wrong" and "we could not reach the
      // server" matters to someone typing a code off their work email.
      return {
        'ok': false,
        'code': 'network_error',
        'message': 'We could not reach ParentVeda. Check your connection '
            'and try again.',
      };
    }
  }

  @visibleForTesting
  void setForTest({Set<String>? capabilities, SponsorInfo? sponsor}) {
    _capabilities = capabilities ?? const {};
    _sponsor = sponsor;
    _loaded = true;
    notifyListeners();
  }
}

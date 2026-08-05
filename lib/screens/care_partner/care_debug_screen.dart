// =============================================================================
//  Care Partner workbench — watch a scan turn into an attribution
// -----------------------------------------------------------------------------
//  THIS SCREEN EXISTS BECAUSE THE REAL PATH CANNOT BE TESTED YET.
//
//  A poster scan reaches the app through the Play Install Referrer, and that
//  needs a live Play listing. `APP_LIVE` on the website is false and
//  /.well-known/assetlinks.json is a 404, so today nobody can walk the actual
//  chain end to end. Waiting for a store listing to find out whether the
//  plumbing works is how you discover a broken funnel after the posters are
//  printed.
//
//  So this simulates the two entry points, exactly as the production code sees
//  them:
//
//    1. A DEEP LINK   — /care/<TOKEN>?ch=… , as if the OS handed it over.
//    2. A PLAY REFERRER — utm_source=care&utm_content=<TOKEN>… , the string
//       Google hands back on first launch after an install.
//
//  Both go through the real ReferralLinks.handleLink and
//  InstallReferrerService parsers. Nothing here reimplements them — a debug
//  tool that fakes the logic it is testing proves nothing.
//
//  It also shows the state that is otherwise invisible: what token is being
//  held, what attribution bound, and which journey events have been written.
//  The Care Partner module is deliberately quiet in the product, and quiet
//  features are the ones that rot without anybody noticing.
//
//  Debug-gated at the call site (Tools), like Brand Studio (debug).
// =============================================================================

import 'package:flutter/material.dart';

import '../../care_partner/care_config.dart';
import '../../care_partner/care_journey.dart';
import '../../care_partner/care_partner_engine.dart';
import '../../care_partner/care_partner_models.dart';
import '../../care_partner/care_partner_store.dart';
import '../../care_partner/care_presence_store.dart';
import '../../referral/install_referrer.dart';
import '../../referral/referral_links.dart';
import '../../services/remote/supabase_repo.dart';
import '../post_pregnancy/pp_common.dart';
import 'care_circle_screen.dart';
import '../../localization/app_language.dart';

class CareDebugScreen extends StatefulWidget {
  const CareDebugScreen({super.key});

  @override
  State<CareDebugScreen> createState() => _CareDebugScreenState();
}

class _CareDebugScreenState extends State<CareDebugScreen> {
  final _store = CarePartnerStore.instance;
  final _token = TextEditingController();
  String _log = '';
  List<Map<String, dynamic>> _partners = const [];

  @override
  void initState() {
    super.initState();
    _store.init();
    CarePresenceStore.instance.init();
    _loadPartners();
  }

  @override
  void dispose() {
    _token.dispose();
    super.dispose();
  }

  Future<void> _loadPartners() async {
    try {
      final refs = await SupabaseRepo.selectAll('partner_referrals');
      final ps = await SupabaseRepo.selectAll('care_partners');
      final byId = {for (final p in ps.whereType<Map>()) '${p['id']}': p};
      final rows = refs
          .whereType<Map>()
          .where((r) => r['active'] as bool? ?? true)
          .map((r) => {
                'token': '${r['token']}',
                'channel': '${r['channel']}',
                'partner': '${byId['${r['partner_id']}']?['name'] ?? r['partner_id']}',
                'status': '${byId['${r['partner_id']}']?['status'] ?? '?'}',
                'expired': r['expires_at'] != null &&
                    DateTime.tryParse('${r['expires_at']}')
                            ?.isBefore(DateTime.now()) ==
                        true,
              })
          .toList();
      if (mounted) setState(() => _partners = rows);
    } catch (e) {
      _say('could not load tokens: $e');
    }
  }

  void _say(String s) {
    if (!mounted) return;
    setState(() => _log = '$s\n$_log');
  }

  // ---- the two entry points, through the REAL parsers ----------------------

  void _simulateDeepLink() {
    final t = _token.text.trim();
    if (t.isEmpty) return _say('enter a token first');
    final uri = Uri.parse(CarePartnerEngine.linkFor(t));
    ReferralLinks.handleLink(uri);
    _say('deep link  $uri\n  held: ${_store.pendingToken ?? "(nothing)"}');
  }

  void _simulateInstallReferrer() {
    final t = _token.text.trim();
    if (t.isEmpty) return _say('enter a token first');
    // Byte-for-byte what parentveda.in puts in the Play referrer.
    final raw = 'utm_source=care&utm_medium=partner&utm_content=$t&utm_term=qr';
    final parsed = InstallReferrerService.partnerTokenFromReferrer(raw);
    if (parsed == null) {
      return _say('referrer REJECTED (malformed token?)\n  $raw');
    }
    _store.holdToken(parsed,
        channel: InstallReferrerService.partnerChannelFromReferrer(raw),
        campaignId: InstallReferrerService.partnerCampaignFromReferrer(raw));
    _say('play referrer  $raw\n  parsed: $parsed  held: ${_store.pendingToken}');
  }

  Future<void> _bind() async {
    if (!SupabaseRepo.isLoggedIn) return _say('not signed in — cannot bind');
    final refusal = await _store.applyPending();
    await _store.refreshFromServer();
    _say(refusal == null
        ? 'BOUND. partner: ${_store.partner?.name ?? "(none)"}'
        : 'refused: $refusal');
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final a = _store.attribution;
        return Scaffold(
          backgroundColor: ppBg,
          appBar: AppBar(
            backgroundColor: ppBg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text(S.now.uiCarePartnerDebug, style: ppJakarta(16)),
          ),
          body: ListView(
            padding: const EdgeInsets.fromLTRB(18, 4, 18, 40),
            children: [
              Text(
                'The real path needs a Play listing (APP_LIVE is false and '
                'assetlinks.json is a 404). This walks the same parsers with a '
                'simulated link and referrer.',
                style: ppBody(12, h: 1.5),
              ),
              const SizedBox(height: 16),

              _label('LIVE TOKENS'),
              if (_partners.isEmpty)
                _note('none loaded — sign in, and run the demo seeds')
              else
                for (final p in _partners) _tokenRow(p),

              const SizedBox(height: 18),
              _label('TOKEN'),
              const SizedBox(height: 6),
              TextField(
                controller: _token,
                textCapitalization: TextCapitalization.characters,
                decoration: InputDecoration(
                  hintText: 'KM7QX2PDVR',
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: ppBorder)),
                ),
              ),
              const SizedBox(height: 12),
              _btn('1 · Simulate a deep link', _simulateDeepLink),
              _btn('1b · Simulate a Play install referrer',
                  _simulateInstallReferrer),
              _btn('2 · Bind it to this account', _bind),
              _btn('Open the Care Circle', () {
                Navigator.of(context).push(MaterialPageRoute<void>(
                    builder: (_) => const CareCircleScreen()));
              }),

              const SizedBox(height: 18),
              _label('STATE'),
              _kv('pending token', _store.pendingToken ?? '—'),
              _kv('attributed', a == null ? 'no' : 'yes'),
              if (a != null) ...[
                _kv('partner', _store.partner?.name ?? a.partnerId),
                _kv('type',
                    _store.partner == null
                        ? '—'
                        : CarePartnerType.label(_store.partner!.type)),
                _kv('channel', a.channel.label),
                _kv('campaign', a.campaignId ?? '—'),
                _kv('scanned', a.scannedAt?.toIso8601String() ?? '—'),
                _kv('installed', a.installedAt?.toIso8601String() ?? '—'),
                _kv('signed up', a.signedUpAt?.toIso8601String() ?? '—'),
              ],
              _kv('attribution model', CareConfig.instance.attributionModel),
              _kv('window (days)',
                  '${CareConfig.instance.attributionWindowDays}'),
              _kv('token rotation', '${CareConfig.instance.tokenRotation}'),

              const SizedBox(height: 18),
              _label('WRITE A JOURNEY EVENT'),
              _note('These are what the partner\'s impact counts. Each one is '
                  'a no-op unless an attribution exists.'),
              Wrap(spacing: 8, runSpacing: 8, children: [
                _chip('pregnancy', CareJourney.pregnancyStarted),
                _chip('child', CareJourney.childBorn),
                _chip('consult done', CareJourney.consultationDone),
                _chip('vaccination', CareJourney.vaccinationDone),
                _chip('guide read', CareJourney.guideRead),
              ]),

              const SizedBox(height: 18),
              _label('STARTING OVER'),
              _btn('Clear the held token', () {
                _store.clearPending();
                _say('pending cleared');
              }),
              _note(
                'To bind a SECOND time you have to delete the server row — '
                'clearing local state will not do it. partner_attributions has '
                'user_id as its primary key, so first touch wins in the '
                'database, not in the app, and a re-bind is refused with '
                '"already_attributed". That is the feature working.  '
                'To start over, in the SQL editor: '
                'delete from partner_attributions where user_id = auth.uid();',
              ),

              const SizedBox(height: 18),
              _label('LOG'),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ppBorder)),
                child: Text(_log.isEmpty ? '—' : _log,
                    style: const TextStyle(
                        fontFamily: 'monospace', fontSize: 11, height: 1.5)),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _label(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 6),
        child: Text(s, style: ppJakarta(10.5, color: ppSoft)),
      );

  Widget _note(String s) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: Text(s, style: ppBody(11.5, h: 1.45)),
      );

  Widget _kv(String k, String v) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 3),
        child: Row(children: [
          SizedBox(
              width: 132, child: Text(k, style: ppBody(11.5, color: ppSoft))),
          Expanded(child: Text(v, style: ppJakarta(11.5))),
        ]),
      );

  Widget _tokenRow(Map<String, dynamic> p) => GestureDetector(
        onTap: () => setState(() => _token.text = '${p['token']}'),
        behavior: HitTestBehavior.opaque,
        child: Container(
          margin: const EdgeInsets.only(bottom: 6),
          padding: const EdgeInsets.fromLTRB(12, 9, 12, 9),
          decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(11),
              border: Border.all(color: ppBorder)),
          child: Row(children: [
            Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('${p['token']}  ·  ${p['channel']}',
                        style: ppJakarta(12)),
                    Text(
                        '${p['partner']}  ·  ${p['status']}'
                        '${p['expired'] == true ? '  ·  EXPIRED' : ''}',
                        style: ppBody(10.5)),
                  ]),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 14, color: ppSoft),
          ]),
        ),
      );

  Widget _btn(String label, VoidCallback onTap) => Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            height: 44,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: ppBorder)),
            child: Text(label, style: ppJakarta(12.5, color: ppPurple)),
          ),
        ),
      );

  Widget _chip(String label, VoidCallback fire) => GestureDetector(
        onTap: () {
          fire();
          _say('wrote "$label" '
              '${_store.partner == null ? "(no partner — nothing written)" : ""}');
        },
        behavior: HitTestBehavior.opaque,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
              color: ppPanel, borderRadius: BorderRadius.circular(999)),
          child: Text(label, style: ppJakarta(11.5, color: ppPurple)),
        ),
      );
}

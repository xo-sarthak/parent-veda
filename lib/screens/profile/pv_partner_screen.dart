// =============================================================================
//  PvPartnerScreen — the partner: what they can see, the code, one switch
// -----------------------------------------------------------------------------
//  Flo's Partner page is the reference (docs/PROFILE-AUDIT.md §3): it tells
//  her WHAT HE CAN SEE before she shares anything, then the 3-step invite →
//  pair → share with the code through the OS share sheet.
//
//  ⚠️ ONE SWITCH, THE USER'S CALL (2026-09-19): "Share my week and calendar."
//  He sees her week (or cycle stage), scans and appointments; never her
//  journal, symptoms or records. The per-thing switches are a later addition
//  and a server rule when they come — today the switch is a local preference
//  the partner shell reads (`kPvPartnerShareKey`), written down here so the
//  gap is a handover, not a silent one.
//
//  The pairing code is read from `profiles.pairing_code` exactly as the
//  pregnancy profile's invite card did (the pairing flow is unchanged).
// =============================================================================

import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../localization/app_language.dart';
import '../../models/pv_product.dart' show PvStageCopy;
import '../../services/life_stage_store.dart';
import '../../services/remote/supabase_repo.dart';
import '../../theme/pv_fonts.dart';
import 'pv_you_chrome.dart';

/// Local preference the partner shell reads. True = week + calendar shared.
const String kPvPartnerShareKey = 'pv_partner_share_week';

class PvPartnerScreen extends StatefulWidget {
  const PvPartnerScreen({super.key, required this.stage, this.partnerName});
  final LifeStage stage;
  final String? partnerName;

  @override
  State<PvPartnerScreen> createState() => _PvPartnerScreenState();
}

class _PvPartnerScreenState extends State<PvPartnerScreen> {
  String? _code;
  bool _linked = false;
  bool _share = true;
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _share = prefs.getBool(kPvPartnerShareKey) ?? true;
      final uid = SupabaseRepo.userId;
      if (uid != null) {
        final row = await Supabase.instance.client
            .from('profiles')
            .select('pairing_code, partner_id')
            .eq('id', uid)
            .maybeSingle();
        _code = row?['pairing_code'] as String?;
        _linked = row?['partner_id'] != null;
      }
    } catch (_) {
      /* local-first: the page still renders */
    }
    if (mounted) setState(() => _loading = false);
  }

  Future<void> _setShare(bool v) async {
    setState(() => _share = v);
    try {
      (await SharedPreferences.getInstance()).setBool(kPvPartnerShareKey, v);
    } catch (_) {}
  }

  String get _who => widget.partnerName?.trim().isNotEmpty == true
      ? widget.partnerName!.trim()
      : 'your partner';

  List<String> get _canSee => switch (widget.stage.shopStage) {
    LifeStage.tryingToConceive => [
      'Where you are in the month — the window, not the dates you logged',
      'Appointments and tests you have booked',
      'What you save and share on purpose',
    ],
    LifeStage.pregnancy => [
      'Your week, and what is happening this week',
      'Scans and appointments on the calendar',
      'The Dear Baby letters you mark for both of you',
    ],
    _ => [
      'Your child\'s records — feeds, sleep, growth, vaccines — because they are the child\'s, not yours',
      'Appointments on the calendar',
      'What you save and share on purpose',
    ],
  };

  List<String> get _neverSees => switch (widget.stage.shopStage) {
    LifeStage.tryingToConceive => [
      'Your symptoms and cycle logs',
      'Your journal',
      'Your test readings',
    ],
    LifeStage.pregnancy => [
      'Your symptoms and weight',
      'Your journal',
      'Your records',
    ],
    _ => ['Your journal', 'Your own health notes'],
  };

  void _shareCode() {
    final code = _code;
    if (code == null) return;
    final s = S.now;
    Share.share(s.pairingShareText(code), subject: s.pairingShareSubject);
  }

  @override
  Widget build(BuildContext context) {
    final p = pvStorePalette;
    return Scaffold(
      backgroundColor: p.ground,
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: PvYouTopBar(
              title: _linked ? _who : 'Your partner',
              eyebrow: 'Family',
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
            sliver: SliverList.list(
              children: [
                if (_loading)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Center(
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  )
                else ...[
                  Text(
                    _linked
                        ? '$_who is paired with you. Here is exactly what that means.'
                        : 'Pair once and $_who gets their own side of ParentVeda, in step with yours. Here is exactly what they would see.',
                    style: pvManrope(
                      fontSize: 14.5,
                      height: 1.5,
                      color: p.ink2,
                    ),
                  ),
                  const SizedBox(height: 18),
                  _list(
                    p,
                    'What $_who can see',
                    _canSee,
                    Icons.check_rounded,
                    pvToneColor(0),
                  ),
                  const SizedBox(height: 12),
                  _list(
                    p,
                    'Never',
                    _neverSees,
                    Icons.close_rounded,
                    pvToneColor(2),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                      border: Border.all(color: kPvLine),
                    ),
                    child: PvYouSwitchRow(
                      icon: Icons.calendar_month_outlined,
                      title: 'Share my week and calendar',
                      subtitle:
                          'Off, and $_who sees only what you share on purpose.',
                      value: _share,
                      onChanged: _setShare,
                    ),
                  ),
                  const SizedBox(height: 22),
                  if (!_linked) ...[
                    Text(
                      'How pairing works',
                      style: pvManrope(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: p.ink1,
                      ),
                    ),
                    const SizedBox(height: 10),
                    _step(
                      p,
                      '1',
                      'Share your code',
                      'It opens a link to download ParentVeda.',
                    ),
                    _step(
                      p,
                      '2',
                      '$_who enters it',
                      'At sign-in, on their own phone.',
                    ),
                    _step(
                      p,
                      '3',
                      'You are paired',
                      'Their home follows your stage from that moment.',
                    ),
                    const SizedBox(height: 16),
                    if (_code != null)
                      PvWell(
                        child: Column(
                          children: [
                            Text(
                              'YOUR CODE',
                              style: pvManrope(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 1.1,
                                color: p.ink3,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              _code!,
                              style: pvFraunces(
                                fontSize: 34,
                                fontWeight: FontWeight.w500,
                                letterSpacing: 4,
                                color: p.ink1,
                              ),
                            ),
                          ],
                        ),
                      )
                    else
                      PvWell(
                        child: Text(
                          'Sign in to get your pairing code.',
                          style: pvManrope(fontSize: 13.5, color: p.ink2),
                        ),
                      ),
                    const SizedBox(height: 12),
                    PvCommit(
                      label: 'Share the code',
                      icon: Icons.ios_share_rounded,
                      onTap: _code == null ? null : _shareCode,
                    ),
                  ] else
                    PvWell(
                      child: Text(
                        'To unpair, $_who signs out on their phone; your data never left yours. If you need it undone from here, write to us from Help.',
                        style: pvManrope(
                          fontSize: 13,
                          height: 1.45,
                          color: p.ink2,
                        ),
                      ),
                    ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _list(
    dynamic p,
    String title,
    List<String> items,
    IconData icon,
    Color c,
  ) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: kPvLine),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: pvManrope(
            fontSize: 14,
            fontWeight: FontWeight.w800,
            color: p.ink1,
          ),
        ),
        const SizedBox(height: 8),
        for (final t in items)
          Padding(
            padding: const EdgeInsets.only(bottom: 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Icon(icon, size: 15, color: c),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    t,
                    style: pvManrope(
                      fontSize: 13.5,
                      height: 1.4,
                      color: p.ink2,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    ),
  );

  Widget _step(dynamic p, String n, String title, String body) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 26,
          height: 26,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: p.surfaceAlt,
            shape: BoxShape.circle,
          ),
          child: Text(
            n,
            style: pvManrope(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: p.ink1,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: pvManrope(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: p.ink1,
                ),
              ),
              Text(
                body,
                style: pvManrope(fontSize: 12.5, height: 1.4, color: p.ink3),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

// =============================================================================
//  The doctor's referral kit — the QR code that starts everything
// -----------------------------------------------------------------------------
//  Every other file in this module handles what happens AFTER a parent scans.
//  This is the scan. Without it the platform has an attribution engine, a
//  visibility system and an impact dashboard, and no way for a single family to
//  ever enter any of them.
//
//  Three channels, one token each:
//    QR        — printed and stuck on the consulting-room wall.
//    WhatsApp  — sent to a patient after a visit.
//    Link      — pasted anywhere else.
//
//  The token is IDENTICAL across all three; only the ?ch= differs, so the
//  dashboard can tell a poster from a message without ever needing separate
//  codes to keep track of. A doctor should be able to print one poster and
//  never think about it again.
//
//  Deliberately absent: any claim about what the doctor will earn. This screen
//  is handed to patients' eyes as often as to the doctor's, and a QR poster
//  that mentions commission is a different object entirely.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../care_partner/care_partner_engine.dart';
import '../../care_partner/care_partner_models.dart';
import '../../care_partner/partner_dashboard_store.dart';
import '../../doctor/doctor_session.dart';
import '../post_pregnancy/pp_common.dart';
import 'care_poster_screen.dart';

class DoctorReferralKitScreen extends StatefulWidget {
  const DoctorReferralKitScreen({super.key});

  @override
  State<DoctorReferralKitScreen> createState() =>
      _DoctorReferralKitScreenState();
}

class _DoctorReferralKitScreenState extends State<DoctorReferralKitScreen> {
  final _store = PartnerDashboardStore.instance;

  @override
  void initState() {
    super.initState();
    // force: true — ASK THE SERVER EVERY TIME THIS SCREEN OPENS.
    //
    // PartnerDashboardStore.load() short-circuits when it has already answered
    // for this session, which is right for the dashboard's numbers and wrong
    // here. Once it had answered "no partner", nothing in the app could make
    // it ask again: neither pull-to-refresh gesture touches this store, so a
    // doctor whose account was linked while the app was open saw "Not set up
    // yet" until they force-stopped it. That is indistinguishable from being
    // genuinely unapproved.
    //
    // This screen opens rarely and the call is three RPCs, so re-asking costs
    // nothing worth counting.
    _store.load(DoctorSession.instance.sessionKey, force: true);
  }

  Future<void> _recheck() async {
    await _store.load(DoctorSession.instance.sessionKey, force: true);
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _store,
      builder: (context, _) {
        final partner = _store.partner;
        final token = _store.token;
        return Scaffold(
          backgroundColor: ppBg,
          appBar: AppBar(
            backgroundColor: ppBg,
            surfaceTintColor: Colors.transparent,
            elevation: 0,
            title: Text('Your referral kit', style: ppJakarta(16)),
          ),
          // A partner with no server-issued token is NOT set up, whatever the
          // rest of their profile says. Printing a computed one would give
          // them a QR that scans, looks right, and credits nobody.
          body: (partner == null || token == null)
              ? _notYetAPartner(hasPartner: partner != null)
              : _kit(partner, token),
        );
      },
    );
  }

  /// A doctor who has not been approved yet gets a straight answer rather than
  /// a broken QR. Approval is an editorial act in the admin panel — see
  /// docs/ADMIN-PANEL.md — and pretending otherwise here would produce codes
  /// that fail at the moment a patient scans them, in front of the doctor.
  Widget _notYetAPartner({bool hasPartner = false}) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 30, 24, 24),
        child: Column(children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
                color: ppPanel, borderRadius: BorderRadius.circular(16)),
            child: Column(children: [
              const Icon(Icons.qr_code_2_rounded, size: 44, color: ppPurple),
              const SizedBox(height: 14),
              Text('Not set up yet',
                  textAlign: TextAlign.center, style: ppJakarta(15)),
              const SizedBox(height: 6),
              Text(
                hasPartner
                    ? 'Your profile is here, but no referral code has been '
                        'issued yet. Write to us and we will set yours up.'
                    : 'Referral codes are issued by ParentVeda once your '
                        'profile is verified. Write to us and we will set '
                        'yours up.',
                textAlign: TextAlign.center,
                style: ppBody(12.5, h: 1.55),
              ),
              // A way to ask again without restarting the app. Whoever is
              // setting a doctor up is usually doing it WHILE they are sitting
              // with the app open, and the answer changes the moment the link
              // lands.
              const SizedBox(height: 16),
              GestureDetector(
                onTap: () async {
                  await _recheck();
                  // `mounted` on the State, not on the captured context — the
                  // analyzer is right that they are different questions, and
                  // this closure outlives the build that made it.
                  if (!mounted) return;
                  if (_store.partner == null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Still not set up — nothing has changed '
                            'on our side yet.'),
                        behavior: SnackBarBehavior.floating,
                      ),
                    );
                  }
                },
                behavior: HitTestBehavior.opaque,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 11),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ppBorder),
                  ),
                  child: Row(mainAxisSize: MainAxisSize.min, children: [
                    const Icon(Icons.refresh_rounded,
                        size: 16, color: ppPurple),
                    const SizedBox(width: 8),
                    Text('Check again',
                        style:
                            ppBody(13, color: ppPurple, w: FontWeight.w800)),
                  ]),
                ),
              ),
            ]),
          ),
        ]),
      );

  Widget _kit(CarePartner partner, String token) {
    final qrLink = CarePartnerEngine.linkFor(token);
    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 4, 20, 40),
      children: [
        Text(
          'Patients who scan this land in ParentVeda already knowing you sent '
          'them.',
          style: ppBody(13, h: 1.55),
        ),
        const SizedBox(height: 20),
        Center(
          child: Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(22),
              border: Border.all(color: ppBorder),
            ),
            child: Column(children: [
              QrImageView(
                // The encoded URL is private inside QrImageView, so it is
                // carried on the key as well: a QR that silently encodes the
                // wrong link is not something anyone would notice by looking.
                key: ValueKey('care-qr:$qrLink'),
                data: qrLink,
                size: 208,
                backgroundColor: Colors.white,
                // Medium: survives a scuffed printed poster without making the
                // pattern so dense that a phone camera struggles across a desk.
                errorCorrectionLevel: QrErrorCorrectLevel.M,
              ),
              const SizedBox(height: 14),
              Text(partner.name, style: ppJakarta(14)),
              if (partner.subtitle.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(partner.subtitle, style: ppBody(11.5)),
              ],
            ]),
          ),
        ),
        const SizedBox(height: 20),
        _codeRow(token),
        const SizedBox(height: 12),
        _action(
          Icons.chat_bubble_outline_rounded,
          'Send on WhatsApp',
          'A message a patient can tap after their visit.',
          () => _share(ReferralChannel.whatsapp, partner),
        ),
        _action(
          Icons.link_rounded,
          'Copy the link',
          'For your website, bio or an email signature.',
          () => _copy(
              CarePartnerEngine.linkFor(token, channel: ReferralChannel.link)),
        ),
        // The poster is the one that matters: before this a partner could see
        // the code and share a LINK, but had no way to get an IMAGE out of the
        // app, so anything reaching a clinic wall was a screenshot.
        _action(
          Icons.image_outlined,
          'Get your poster',
          'A ParentVeda card with your QR — save it or send it.',
          () => Navigator.of(context).push(MaterialPageRoute<void>(
              builder: (_) =>
                  CarePosterScreen(partner: partner, token: token))),
        ),
        _action(
          Icons.link_rounded,
          'Share the link',
          'Send this to whoever prints for your clinic.',
          () => _share(ReferralChannel.qr, partner),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
          decoration: BoxDecoration(
              color: ppPanel, borderRadius: BorderRadius.circular(13)),
          child: Text(
            'The same code works everywhere — you never need a second one. '
            'ParentVeda can still tell a poster scan from a WhatsApp tap.',
            style: ppBody(11.5, h: 1.5),
          ),
        ),
      ],
    );
  }

  Widget _codeRow(String token) => Container(
        padding: const EdgeInsets.fromLTRB(16, 13, 10, 13),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: ppBorder),
        ),
        child: Row(children: [
          Expanded(
            child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('YOUR CODE', style: ppJakarta(9.5, color: ppSoft)),
                  const SizedBox(height: 4),
                  Text(token, style: ppJakarta(19, color: ppPurple)),
                ]),
          ),
          TextButton(
            onPressed: () => _copy(token),
            child: Text('Copy', style: ppJakarta(12.5, color: ppPurple)),
          ),
        ]),
      );

  Widget _action(
          IconData icon, String title, String sub, VoidCallback onTap) =>
      Padding(
        padding: const EdgeInsets.only(bottom: 10),
        child: GestureDetector(
          onTap: onTap,
          behavior: HitTestBehavior.opaque,
          child: Container(
            padding: const EdgeInsets.fromLTRB(14, 13, 14, 13),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: ppBorder),
            ),
            child: Row(children: [
              Icon(icon, size: 19, color: ppPurple),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(title, style: ppJakarta(13)),
                      const SizedBox(height: 2),
                      Text(sub, style: ppBody(11.5, h: 1.4)),
                    ]),
              ),
              const Icon(Icons.arrow_forward_rounded, size: 16, color: ppSoft),
            ]),
          ),
        ),
      );

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(const SnackBar(content: Text('Copied')));
  }

  void _share(ReferralChannel channel, CarePartner partner) {
    final token = _store.token;
    if (token == null) return;
    final link = CarePartnerEngine.linkFor(token, channel: channel);
    // Written in the doctor's voice, for the patient to read. No mention of
    // what anyone earns.
    Share.share(
      'I use ParentVeda with my patients — week-by-week guidance you can '
      'trust, and my notes reach you there.\n\n$link',
    );
  }
}

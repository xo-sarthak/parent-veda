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
//
//  2026-09-21: moved onto the doctor chrome. It was the last screen in the
//  doctor app still drawn in the parenting palette — violet code, violet
//  icons, Jakarta headings, a tinted panel at the foot — and the user saw it
//  at once: "very purple, not needed". Same content; DcScreen, DcCard, rows
//  with drawn marks, a textual note. The one brand colour left is
//  WhatsApp's own green on its own glyph, because that is how a channel is
//  recognised.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';

import '../../care_partner/care_partner_engine.dart';
import '../../care_partner/care_partner_models.dart';
import '../../care_partner/partner_dashboard_store.dart';
import '../../doctor/doctor_session.dart';
import '../v2/v2_palette.dart' show v2BlockTint;
import 'care_poster_screen.dart';
import 'doctor_art.dart';
import 'doctor_chrome.dart';

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
    // The setup carousel's "Print your QR poster" ticks off when the kit
    // has been opened once — the nearest honest proxy for a printer.
    DoctorSession.instance.markQrKitOpened();
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
        // A partner with no server-issued token is NOT set up, whatever the
        // rest of their profile says. Printing a computed one would give
        // them a QR that scans, looks right, and credits nobody.
        final ready = partner != null && token != null;
        return DcScreen(
          title: 'Your referral kit',
          subtitle: ready
              ? 'Patients who scan this land in ParentVeda already knowing you sent them.'
              : 'Not set up yet',
          onRefresh: _recheck,
          children: ready ? _kit(partner, token) : _notYetAPartner(hasPartner: partner != null),
        );
      },
    );
  }

  /// A doctor who has not been approved yet gets a straight answer rather than
  /// a broken QR. Approval is an editorial act in the admin panel — see
  /// docs/ADMIN-PANEL.md — and pretending otherwise here would produce codes
  /// that fail at the moment a patient scans them, in front of the doctor.
  List<Widget> _notYetAPartner({bool hasPartner = false}) => [
        DcEmpty(
          'Your code is on its way',
          hasPartner
              ? 'Your profile is here, but no referral code has been issued yet. '
                  'Write to partners@parentveda.com and we set yours up.'
              : 'Referral codes are issued by ParentVeda once your profile is '
                  'verified. Write to partners@parentveda.com and we set yours up.',
          mark: DoctorMark.qr,
          action: 'Check again',
          // A way to ask again without restarting the app. Whoever is
          // setting a doctor up is usually doing it WHILE they are sitting
          // with the app open, and the answer changes the moment the link
          // lands.
          onAction: () async {
            await _recheck();
            // `mounted` on the State, not on the captured context — the
            // analyzer is right that they are different questions, and
            // this closure outlives the build that made it.
            if (!mounted) return;
            if (_store.partner == null) dcToast(context, 'Still not set up — nothing has changed on our side yet.');
          },
        ),
      ];

  List<Widget> _kit(CarePartner partner, String token) {
    final p = dcP;
    final qrLink = CarePartnerEngine.linkFor(token);
    return [
      // The code itself: white card, the QR, her name under it — what the
      // poster will carry.
      DcCard(
        padding: const EdgeInsets.fromLTRB(18, 22, 18, 18),
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
          Text(partner.name, style: dcStrong(15.5)),
          if (partner.subtitle.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(partner.subtitle, style: dcMeta(12.5)),
          ],
        ]),
      ),
      const SizedBox(height: 16),

      // The code as text, with Copy — for the doctor who types it into a
      // website or reads it out over the phone.
      DcRowGroup(children: [
        DcRow(
          mark: DoctorMark.qr,
          title: token,
          subtitle: 'Your code. The same one everywhere.',
          trailing: Text('Copy', style: dcStrong(14, color: p.action)),
          chevron: false,
          onTap: () => _copy(token),
        ),
      ]),
      const SizedBox(height: 22),

      const DcSectionHead('Share it'),
      DcRowGroup(children: [
        DcRow(
          leading: _WhatsAppTile(p: p),
          title: 'Send on WhatsApp',
          subtitle: 'A message a patient can tap after their visit.',
          onTap: () => _share(ReferralChannel.whatsapp, partner),
        ),
        DcRow(
          mark: DoctorMark.inbox,
          title: 'Copy the link',
          subtitle: 'For your website, bio or an email signature.',
          onTap: () => _copy(CarePartnerEngine.linkFor(token, channel: ReferralChannel.link)),
        ),
        // The poster is the one that matters: before this a partner could see
        // the code and share a LINK, but had no way to get an IMAGE out of the
        // app, so anything reaching a clinic wall was a screenshot.
        DcRow(
          mark: DoctorMark.photo,
          title: 'Get your poster',
          subtitle: 'A ParentVeda card with your QR — save it or send it.',
          onTap: () => Navigator.of(context).push(MaterialPageRoute<void>(
              settings: const RouteSettings(name: 'doctor/poster'),
              builder: (_) => CarePosterScreen(partner: partner, token: token))),
        ),
        DcRow(
          mark: DoctorMark.referral,
          title: 'Send the poster',
          subtitle: 'Opens your share sheet — send it to whoever prints for your clinic.',
          onTap: () => _share(ReferralChannel.qr, partner),
        ),
      ]),
      const SizedBox(height: 16),
      const DcNotice(
        'The same code works everywhere — you never need a second one. '
        'ParentVeda can still tell a poster scan from a WhatsApp tap.',
      ),
    ];
  }

  void _copy(String text) {
    Clipboard.setData(ClipboardData(text: text));
    if (!mounted) return;
    dcToast(context, 'Copied');
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

/// WhatsApp's own glyph in WhatsApp's own green, in the same 44pt well the
/// drawn marks use. A channel is recognised by its mark; a generic speech
/// bubble made the doctor read the row twice. The path is Simple Icons'
/// (CC0). The green is the one saturated colour on this screen that is not
/// ours, and it is here because it is theirs.
class _WhatsAppTile extends StatelessWidget {
  const _WhatsAppTile({required this.p});
  final dynamic p;

  static const _green = Color(0xFF25D366);
  static const _path =
      'M17.472 14.382c-.297-.149-1.758-.867-2.03-.967-.273-.099-.471-.148-.67.15-.197.297-.767.966-.94 1.164-.173.199-.347.223-.644.075-.297-.15-1.255-.463-2.39-1.475-.883-.788-1.48-1.761-1.653-2.059-.173-.297-.018-.458.13-.606.134-.133.298-.347.446-.52.149-.174.198-.298.298-.497.099-.198.05-.371-.025-.52-.075-.149-.669-1.612-.916-2.207-.242-.579-.487-.5-.669-.51-.173-.008-.371-.01-.57-.01-.198 0-.52.074-.792.372-.272.297-1.04 1.016-1.04 2.479 0 1.462 1.065 2.875 1.213 3.074.149.198 2.096 3.2 5.077 4.487.709.306 1.262.489 1.694.625.712.227 1.36.195 1.871.118.571-.085 1.758-.719 2.006-1.413.248-.694.248-1.289.173-1.413-.074-.124-.272-.198-.57-.347m-5.421 7.403h-.004a9.87 9.87 0 01-5.031-1.378l-.361-.214-3.741.982.998-3.648-.235-.374a9.86 9.86 0 01-1.51-5.26c.001-5.45 4.436-9.884 9.888-9.884 2.64 0 5.122 1.03 6.988 2.898a9.825 9.825 0 012.893 6.994c-.003 5.45-4.437 9.885-9.885 9.885m8.413-18.297A11.815 11.815 0 0012.05 0C5.495 0 .16 5.335.157 11.892c0 2.096.547 4.142 1.588 5.945L.057 24l6.305-1.654a11.882 11.882 0 005.683 1.448h.005c6.554 0 11.89-5.335 11.893-11.893a11.821 11.821 0 00-3.48-8.413Z';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: v2BlockTint(142, p), borderRadius: BorderRadius.circular(13)),
      child: SvgPicture.string(
        '<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 24 24"><path fill="#25D366" d="$_path"/></svg>',
        width: 24,
        height: 24,
        colorFilter: const ColorFilter.mode(_green, BlendMode.srcIn),
      ),
    );
  }
}

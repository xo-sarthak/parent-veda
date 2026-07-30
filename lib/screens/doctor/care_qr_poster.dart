// =============================================================================
//  The referral poster — a partner's QR on a ParentVeda template
// -----------------------------------------------------------------------------
//  We are not a print shop. This is one designed card a partner can save or
//  send, so what goes on a clinic wall looks like ParentVeda rather than a
//  screenshot of an app. Nothing here manages stock, sizes or bleed.
//
//  IT IS READ BY PATIENTS, NOT BY THE PARTNER. That single fact decides the
//  content:
//
//   * No mention of money. Not commission, not earnings, not "partner
//     programme". A poster on a waiting-room wall that hints at a commercial
//     arrangement makes the recommendation worth less than saying nothing.
//   * The code is printed as text under the QR. A phone with a cracked camera,
//     an older patient, bad light — the fallback has to be on the paper, and on
//     iOS manual entry is the ONLY mechanism (Apple has no install referrer).
//   * The partner's name is the largest thing after the QR, because the trust
//     is theirs. Ours is a small mark at the foot.
//
//  Built in Flutter and exported through MemoryExport — the same
//  RepaintBoundary -> toImage(x3) -> PNG path the Memories cards use, so a
//  1080-wide image comes out of a 360-wide layout. No assets to ship, crisp at
//  any size.
//
//  FIXED SIZE, never scrolling. It is exported as an image, so an overflow
//  stripe would be baked into the file. Every text block scales down inside a
//  FittedBox rather than pushing the layout — the lesson from the Memories
//  templates, where a card overflowed by 11px with an empty message.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../care_partner/care_partner_models.dart';
import '../post_pregnancy/pp_common.dart';

/// Poster shapes. Portrait is the one to print; square is the one to send.
enum CarePosterFormat { portrait, square }

extension CarePosterFormatX on CarePosterFormat {
  /// Logical size. Export multiplies by 3 for a 1080-wide image.
  Size get size => this == CarePosterFormat.portrait
      ? const Size(360, 510) // ~A4 proportion
      : const Size(360, 360);

  String get label =>
      this == CarePosterFormat.portrait ? 'Poster' : 'For sharing';
}

class CareQrPoster extends StatelessWidget {
  const CareQrPoster({
    super.key,
    required this.partner,
    required this.link,
    required this.token,
    this.format = CarePosterFormat.portrait,
  });

  final CarePartner partner;

  /// The full `/care/<TOKEN>` URL, already carrying its channel.
  final String link;

  /// Printed under the QR for anyone who cannot scan.
  final String token;

  final CarePosterFormat format;

  @override
  Widget build(BuildContext context) {
    final portrait = format == CarePosterFormat.portrait;
    final qrSize = portrait ? 168.0 : 132.0;

    return SizedBox(
      width: format.size.width,
      height: format.size.height,
      child: DecoratedBox(
        decoration: const BoxDecoration(color: Colors.white),
        child: Stack(children: [
          // A soft band behind the top third, so the card reads as designed
          // rather than as a QR on a sheet of paper.
          Positioned(
            left: 0,
            right: 0,
            top: 0,
            height: format.size.height * 0.34,
            child: const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFFF3EEF7), Color(0xFFFBF9FE)],
                ),
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(
                portrait ? 30 : 24, portrait ? 30 : 22, portrait ? 30 : 24, 18),
            child: Column(children: [
              // ---- who is inviting -------------------------------------
              Expanded(
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.topCenter,
                  child: SizedBox(
                    width: format.size.width - (portrait ? 60 : 48),
                    child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(partner.trust.safePrimary.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: ppJakarta(9.5, color: ppSoft)
                                  .copyWith(letterSpacing: 2.4)),
                          const SizedBox(height: 6),
                          Text(partner.name,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: ppFraunces(portrait ? 25 : 21, h: 1.12)),
                          if (partner.subtitle.isNotEmpty) ...[
                            const SizedBox(height: 5),
                            Text(partner.subtitle,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: ppBody(11.5, h: 1.4)),
                          ],
                        ]),
                  ),
                ),
              ),
              // ---- the QR ----------------------------------------------
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(color: ppBorder),
                ),
                child: QrImageView(
                  // The encoded URL is private inside QrImageView, so it rides
                  // on the key too: a QR that silently encodes the wrong link
                  // is not something anyone notices by looking at it.
                  key: ValueKey('care-poster-qr:$link'),
                  data: link,
                  size: qrSize,
                  backgroundColor: Colors.white,
                  // Medium survives a scuffed, sun-faded poster without making
                  // the pattern so dense a phone struggles across a desk.
                  errorCorrectionLevel: QrErrorCorrectLevel.M,
                ),
              ),
              const SizedBox(height: 12),
              Text('Scan to join ParentVeda',
                  textAlign: TextAlign.center, style: ppJakarta(13)),
              const SizedBox(height: 4),
              Text(
                'Week-by-week guidance for pregnancy and the early years.',
                textAlign: TextAlign.center,
                maxLines: 2,
                style: ppBody(10.5, h: 1.4),
              ),
              const SizedBox(height: 11),
              // ---- the code, for anyone who cannot scan -----------------
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
                decoration: BoxDecoration(
                  color: ppPanel,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Text('Or enter code  $token',
                    style: ppJakarta(11, color: ppPurple)),
              ),
              const Spacer(),
              Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Icon(Icons.eco_rounded, size: 11, color: ppMuted),
                const SizedBox(width: 4),
                Text('ParentVeda',
                    style: ppJakarta(9.5, color: ppMuted)
                        .copyWith(letterSpacing: 0.4)),
              ]),
            ]),
          ),
        ]),
      ),
    );
  }
}

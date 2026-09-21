// =============================================================================
//  Poster preview — see it, save it, send it
// -----------------------------------------------------------------------------
//  The step that makes the QR usable. Before this a partner could see their
//  code on screen and share a LINK, but had no way to get an image out of the
//  app — so anything going on a clinic wall was a screenshot with app chrome in
//  the frame.
//
//  TWO OUTPUTS, for two different jobs:
//
//    PDF   the one that goes on a wall. A4 plus a cut-in-half A5 pair, and the
//          QR is drawn as VECTOR paths — see care_poster_pdf.dart. This is the
//          launch-critical one: a partner onboarded tomorrow needs something
//          printable today.
//    PNG   for sending. RepaintBoundary -> toImage(×3) -> 1080px, through
//          MemoryExport, the same path the Memories cards use.
//
//  The PNG is deliberately NOT offered as the print option. Upscaled to A4 its
//  QR modules go soft, and a phone camera in a dim waiting room, at an angle,
//  behind glass, often fails on that.
//
//  The preview is SCALED DOWN to fit, never laid out at a different size: the
//  thing exported has to be the thing seen, and a poster that reflows between
//  preview and export is a poster nobody trusts.
// =============================================================================

import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../care_partner/care_partner_engine.dart';
import '../../care_partner/care_partner_models.dart';
import '../../care_partner/care_poster_pdf.dart';
import '../../memories/memory_export.dart';
import 'care_qr_poster.dart';
import 'doctor_art.dart';
import 'doctor_chrome.dart';

class CarePosterScreen extends StatefulWidget {
  const CarePosterScreen({
    super.key,
    required this.partner,
    required this.token,
  });

  final CarePartner partner;
  final String token;

  @override
  State<CarePosterScreen> createState() => _CarePosterScreenState();
}

class _CarePosterScreenState extends State<CarePosterScreen> {
  final _boundary = GlobalKey();
  CarePosterFormat _format = CarePosterFormat.portrait;
  bool _busy = false;

  /// The poster always carries ch=qr. It is the printed surface by definition,
  /// and a poster whose link claimed to be a WhatsApp tap would quietly corrupt
  /// the channel numbers on the partner's own dashboard.
  String get _link =>
      CarePartnerEngine.linkFor(widget.token, channel: ReferralChannel.qr);

  @override
  Widget build(BuildContext context) {
    final size = _format.size;
    // 2026-09-21: onto the doctor chrome — this was one of the last screens
    // still in the parenting palette (violet buttons, a tinted foot panel).
    // The three ways out are rows with drawn marks, like the kit's.
    return DcScreen(
      title: 'Your poster',
      subtitle: 'For a wall, a desk, or a message.',
      children: [
        DcSegments(
          expand: true,
          labels: [for (final f in CarePosterFormat.values) f.label],
          index: CarePosterFormat.values.indexOf(_format),
          onChanged: (i) => setState(() => _format = CarePosterFormat.values[i]),
        ),
        const SizedBox(height: 18),
        // Captured at its LOGICAL size and scaled for display, so the export
        // is identical to the preview.
        Center(
          child: SizedBox(
            width: size.width,
            height: size.height,
            child: FittedBox(
              child: RepaintBoundary(
                key: _boundary,
                child: CareQrPoster(
                  partner: widget.partner,
                  link: _link,
                  token: widget.token,
                  format: _format,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: 22),
        DcRowGroup(children: [
          // The PDF is first because it is the one that goes on a wall. Its QR
          // is drawn as vector paths, so it stays exact at A4 — a 1080px PNG
          // upscaled to that size gives soft-edged modules that a camera in a
          // dim waiting room, at an angle, behind glass, often will not read.
          DcRow(
            mark: DoctorMark.download,
            title: 'Download for printing',
            subtitle: 'A PDF: an A4 poster and a sheet of two smaller ones to cut in half.',
            onTap: _busy ? null : _downloadPdf,
          ),
          DcRow(
            mark: DoctorMark.photo,
            title: 'Save image to photos',
            subtitle: 'The poster as a picture, for sending.',
            onTap: _busy ? null : _save,
          ),
          DcRow(
            mark: DoctorMark.referral,
            title: 'Share image',
            subtitle: 'Opens your share sheet.',
            onTap: _busy ? null : _share,
          ),
        ]),
        const SizedBox(height: 16),
        const DcNotice(
          'Either way the code is printed on it, for anyone whose camera will not scan.',
        ),
      ],
    );
  }

  Future<Uint8List?> _capture() =>
      // ×3: a 360-wide layout becomes 1080 wide.
      MemoryExport.capture(_boundary, 3.0);

  Future<void> _save() async {
    setState(() => _busy = true);
    final bytes = await _capture();
    var ok = false;
    if (bytes != null) ok = await MemoryExport.saveToGallery(bytes);
    if (!mounted) return;
    setState(() => _busy = false);
    dcToast(context, ok ? 'Saved to your photos' : 'Could not save — check photo permissions');
  }

  /// Print, save as PDF, or hand to another app — the OS sheet offers all
  /// three, so a partner with a clinic printer never leaves the app.
  Future<void> _downloadPdf() async {
    setState(() => _busy = true);
    try {
      final bytes = await CarePosterPdf.build(
        partner: widget.partner,
        link: _link,
        token: widget.token,
      );
      await CarePosterPdf.present(partner: widget.partner, bytes: bytes);
    } catch (e) {
      if (mounted) dcToast(context, 'Could not build the PDF: $e');
    }
    if (!mounted) return;
    setState(() => _busy = false);
  }

  Future<void> _share() async {
    setState(() => _busy = true);
    final bytes = await _capture();
    if (bytes != null) {
      // No mention of money in the share text either: the recipient is
      // usually a patient, or whoever prints for the clinic.
      await MemoryExport.share(bytes,
          text: 'Scan to join ParentVeda — ${widget.partner.name}');
    }
    if (!mounted) return;
    setState(() => _busy = false);
  }
}

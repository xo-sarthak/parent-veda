// =============================================================================
//  Her photo — camera or gallery, a look, then it is on the profile
// -----------------------------------------------------------------------------
//  Until 2026-09-21 the set-up rail said "send one to partners@parentveda.com"
//  and the user's answer was the obvious one: apps let you add an image. So:
//  a sheet with two ways in (the camera, the gallery), a square preview of
//  what she chose, one button. The picker does the shrinking (1080 on the
//  long side, quality 85) so a 12-megapixel portrait does not go up the
//  wire; DoctorSession.setPhoto does the rest (0090).
//
//  The preview is the whole point of the middle step. A doctor who picks
//  the wrong picture and sees it land on the profile in front of parents is
//  the failure this avoids; the cost is one extra tap.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../doctor/doctor_session.dart';
import 'doctor_art.dart';
import 'doctor_chrome.dart';

Future<void> showDoctorPhotoSheet(BuildContext context) => dcSheet<void>(
      context,
      title: 'Your photo',
      child: const _PhotoSheetBody(),
    );

class _PhotoSheetBody extends StatefulWidget {
  const _PhotoSheetBody();

  @override
  State<_PhotoSheetBody> createState() => _PhotoSheetBodyState();
}

class _PhotoSheetBodyState extends State<_PhotoSheetBody> {
  XFile? _picked;
  bool _busy = false;
  String? _error;

  Future<void> _pick(ImageSource src) async {
    setState(() => _error = null);
    try {
      final f = await ImagePicker().pickImage(
        source: src,
        maxWidth: 1080,
        maxHeight: 1080,
        imageQuality: 85,
        preferredCameraDevice: CameraDevice.front,
      );
      if (f == null) return;
      setState(() => _picked = f);
    } catch (e) {
      setState(() => _error = 'Could not open the ${src == ImageSource.camera ? 'camera' : 'gallery'}. Check the app\'s permission in Settings.');
    }
  }

  Future<void> _use() async {
    final f = _picked;
    if (f == null) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    final bytes = await f.readAsBytes();
    final err = await DoctorSession.instance.setPhoto(bytes);
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.of(context).pop();
    dcToast(context, 'Your photo is on your profile.');
  }

  Future<void> _remove() async {
    setState(() {
      _busy = true;
      _error = null;
    });
    final err = await DoctorSession.instance.clearPhoto();
    if (!mounted) return;
    setState(() => _busy = false);
    if (err != null) {
      setState(() => _error = err);
      return;
    }
    Navigator.of(context).pop();
    dcToast(context, 'Photo removed.');
  }

  @override
  Widget build(BuildContext context) {
    final p = dcP;
    final current = DoctorSession.instance.profile?.photoUrl;
    final picked = _picked;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Text(
        'Parents choose a face. A clear, front-facing photograph on a plain background — no white coat needed.',
        style: dcBody(15, h: 1.5),
      ),
      const SizedBox(height: 18),
      if (picked != null) ...[
        // The look before it lands: square, the same crop the avatar shows.
        Center(
          child: ClipRRect(
            borderRadius: BorderRadius.circular(24),
            child: SizedBox(
              width: 180,
              height: 180,
              child: FutureBuilder(
                future: picked.readAsBytes(),
                builder: (_, snap) => snap.hasData
                    ? Image.memory(snap.data!, fit: BoxFit.cover)
                    : Container(color: p.surfaceAlt),
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        ObPrimary(p: p, label: _busy ? 'Putting it on your profile…' : 'Use this photo', onTap: _busy ? null : _use),
        const SizedBox(height: 8),
        ObSecondary(p: p, label: 'Choose another', onTap: _busy ? null : () => setState(() => _picked = null)),
      ] else ...[
        DcRowGroup(children: [
          DcRow(
            mark: DoctorMark.photo,
            title: 'Take a photo',
            subtitle: 'Front camera, right now.',
            onTap: _busy ? null : () => _pick(ImageSource.camera),
          ),
          DcRow(
            mark: DoctorMark.upload,
            title: 'Choose from your gallery',
            subtitle: 'A photograph you already have.',
            onTap: _busy ? null : () => _pick(ImageSource.gallery),
          ),
          if (current != null)
            DcRow(
              mark: DoctorMark.cancelled,
              title: 'Remove the current photo',
              subtitle: 'Parents see your initial until you add another.',
              chevron: false,
              onTap: _busy ? null : _remove,
            ),
        ]),
      ],
      if (_error != null) ...[
        const SizedBox(height: 12),
        DcNotice(_error!, problem: true),
      ],
      const SizedBox(height: 8),
    ]);
  }
}

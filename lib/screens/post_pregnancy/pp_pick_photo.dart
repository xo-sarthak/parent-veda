// =============================================================================
//  ppPickPhoto - gallery or camera, one picked image path (R10, 2026-10-26)
// -----------------------------------------------------------------------------
//  The journal's private `_pickPhoto` (journal_capture_screens.dart), made
//  public for the Milestones save. A copy rather than a move: the journal file
//  is being edited in another terminal today, and the two sheets are small
//  enough that one shared helper can replace both on its next pass.
// =============================================================================

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../theme/pv_fonts.dart';
import '../products/pv_store_chrome.dart' show pvStorePalette;
import 'pp_common.dart' show ppBg;

/// Asks gallery or camera, then returns the picked file's temporary path,
/// or null when she backs out or the picker fails.
Future<String?> ppPickPhoto(BuildContext context) async {
  final source = await showModalBottomSheet<ImageSource>(
    context: context,
    backgroundColor: ppBg,
    builder: (ctx) => SafeArea(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        ListTile(
            leading: Icon(Icons.photo_library_outlined, color: pvStorePalette.ink1),
            title: Text('Choose from gallery',
                style: pvManrope(fontSize: 15, fontWeight: FontWeight.w600, color: pvStorePalette.ink1)),
            onTap: () => Navigator.of(ctx).pop(ImageSource.gallery)),
        ListTile(
            leading: Icon(Icons.photo_camera_outlined, color: pvStorePalette.ink1),
            title: Text('Take a photo',
                style: pvManrope(fontSize: 15, fontWeight: FontWeight.w600, color: pvStorePalette.ink1)),
            onTap: () => Navigator.of(ctx).pop(ImageSource.camera)),
      ]),
    ),
  );
  if (source == null) return null;
  try {
    final x = await ImagePicker().pickImage(source: source, maxWidth: 2000, imageQuality: 85);
    return x?.path;
  } catch (_) {
    return null;
  }
}

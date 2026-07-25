// =============================================================================
//  MemoryExport — turn a rendered template into an image, then save / share
// -----------------------------------------------------------------------------
//  The template is rendered at its LOGICAL size (360-wide) inside a
//  RepaintBoundary; capturing that boundary at exportScale (×3) yields a crisp
//  1080-wide PNG regardless of how small it is shown on screen. From there:
//  save to the gallery (gal) or hand it to the native share sheet (share_plus).
//  No server, no upload — the keepsake is made on-device.
// =============================================================================

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

class MemoryExport {
  MemoryExport._();

  /// Capture the RepaintBoundary behind [key] to PNG bytes at [pixelRatio].
  static Future<Uint8List?> capture(GlobalKey key, double pixelRatio) async {
    final boundary =
        key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
    if (boundary == null) return null;
    final image = await boundary.toImage(pixelRatio: pixelRatio);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    return data?.buffer.asUint8List();
  }

  /// Save PNG bytes to the device photo gallery (ParentVeda album). Returns
  /// true on success — false if permission was denied or it failed.
  static Future<bool> saveToGallery(Uint8List bytes) async {
    try {
      await Gal.putImageBytes(bytes, album: 'ParentVeda');
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Hand the image to the OS share sheet — the parent picks WhatsApp,
  /// Instagram, the album, whatever. We never message on their behalf.
  static Future<void> share(Uint8List bytes, {String text = ''}) async {
    final dir = await getTemporaryDirectory();
    final file = File(
        '${dir.path}/memory_${DateTime.now().millisecondsSinceEpoch}.png');
    await file.writeAsBytes(bytes);
    await Share.shareXFiles([XFile(file.path)], text: text);
  }
}

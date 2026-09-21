// =============================================================================
//  DoctorArt — rasterise the family and look at it (DESIGN-SYSTEM §3.5)
// -----------------------------------------------------------------------------
//  Every mark set this app has shipped was checked this way first, and every
//  time it caught something: a leaf for a brain, a dial for an eye. This
//  writes a contact sheet of the twelve doctor marks at 52dp and at 40dp to
//  the scratch folder so a person can look at them before they reach a
//  phone. The assertion is only that the painter did not throw.
// =============================================================================

import 'dart:io';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/screens/doctor/doctor_art.dart';
import 'package:parentveda/screens/v2/v2_palette.dart';

void main() {
  testWidgets('the doctor marks rasterise; contact sheet written', (tester) async {
    await tester.runAsync(() async {
      final p = V2PaletteStore.instance.current;
      const cell = 120.0;
      const cols = 6;
      final marks = DoctorMark.values;
      final rows = (marks.length / cols).ceil();
      final rec = ui.PictureRecorder();
      final canvas = Canvas(rec);
      canvas.drawRect(Rect.fromLTWH(0, 0, cols * cell, rows * cell * 2), Paint()..color = Colors.white);
      for (var i = 0; i < marks.length; i++) {
        final m = marks[i];
        final tint = v2BlockTint(doctorMarkHue(m), p);
        // at 52 (top band) and 40 (bottom band), each on its tile
        for (final (band, side) in const [(0, 52.0), (1, 40.0)]) {
          final x = (i % cols) * cell;
          final y = (i ~/ cols) * cell + band * rows * cell;
          canvas.save();
          canvas.translate(x + (cell - side) / 2, y + (cell - side) / 2);
          canvas.drawRRect(
              RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, side, side), Radius.circular(side * 0.3)),
              Paint()..color = tint);
          canvas.translate(side * 0.2, side * 0.2);
          paintDoctorMark(canvas, m, tint, side * 0.6);
          canvas.restore();
        }
      }
      final img = await rec.endRecording().toImage((cols * cell).toInt(), (rows * cell * 2).toInt());
      final bytes = await img.toByteData(format: ui.ImageByteFormat.png);
      final out = Directory('build/doctor_art');
      out.createSync(recursive: true);
      File('${out.path}/contact_sheet.png').writeAsBytesSync(bytes!.buffer.asUint8List());
      expect(bytes.lengthInBytes, greaterThan(1000));
    });
  });
}

// =============================================================================
//  Area marks are actually distinct, and actually drawn
// -----------------------------------------------------------------------------
//  ⚠️ WRITTEN BECAUSE THE PHONE AND THE DATA DISAGREED.
//
//  Every area in every section carries its own `IntentMark`, and a runtime probe
//  confirmed eleven distinct values in Health alone. The device kept rendering
//  one identical glyph in eleven tints, which left two possibilities that look
//  the same from a screenshot: a stale APK, or a renderer ignoring the field.
//
//  A screenshot cannot tell those apart. This can, and it keeps telling.
// =============================================================================

import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:parentveda/screens/brackets/hub/hub_intent_art.dart';
import 'package:parentveda/screens/post_pregnancy/pp_section_registry.dart';

/// Rasterise one mark and return its pixels.
Future<ui.Image> _render(IntentMark mark) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(const Rect.fromLTWH(0, 0, 100, 100), Paint()..color = Colors.white);
  paintIntentMark(canvas, mark, const Color(0xFFDCD3EA), 100);
  return recorder.endRecording().toImage(100, 100);
}

Future<List<int>> _bytes(IntentMark m) async {
  final img = await _render(m);
  final data = await img.toByteData(format: ui.ImageByteFormat.rawRgba);
  return data!.buffer.asUint8List().toList();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('the data carries distinct marks', () {
    test('no section repeats a mark across its areas', () {
      for (final s in kPpSections) {
        final marks = [for (final a in s.areas) a.mark];
        expect(marks.toSet().length, marks.length,
            reason: '${s.id} repeats a mark: '
                '${marks.map((m) => m.name).join(", ")}');
      }
    });

    test('and a section does not sit on the default', () {
      // `listMark` is PpArea's default. A whole section on the default means the
      // assignment pass missed the file entirely.
      for (final s in kPpSections) {
        final defaults =
            s.areas.where((a) => a.mark == IntentMark.listMark).length;
        expect(defaults, lessThan(2), reason: '${s.id} is mostly unassigned');
      }
    });
  });

  group('and the painter actually draws them differently', () {
    // ⚠️ THE HALF THAT MATTERS. Distinct enum values prove nothing if the
    // painter falls through to one shape, and no amount of reading the data
    // catches that.
    testWidgets('four different marks rasterise to four different images',
        (tester) async {
      await tester.runAsync(() async {
        const sample = [
          IntentMark.askDoctor,
          IntentMark.bodyMark,
          IntentMark.listMark,
          IntentMark.blocksMark,
          IntentMark.scaleMark,
        ];
        final rendered = <IntentMark, List<int>>{};
        for (final m in sample) {
          rendered[m] = await _bytes(m);
        }
        for (var i = 0; i < sample.length; i++) {
          for (var j = i + 1; j < sample.length; j++) {
            final a = rendered[sample[i]]!;
            final b = rendered[sample[j]]!;
            var diff = 0;
            for (var k = 0; k < a.length; k += 4) {
              if ((a[k] - b[k]).abs() > 8) diff++;
            }
            expect(diff, greaterThan(50),
                reason: '${sample[i].name} and ${sample[j].name} rasterise to '
                    'nearly the same image ($diff pixels differ)');
          }
        }
      });
    });
  });
}

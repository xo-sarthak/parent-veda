// =============================================================================
//  The key builders must produce keys the manifest actually has
// -----------------------------------------------------------------------------
//  A wrong narration key is the quietest bug in this feature. It is not an
//  error and nothing goes red: NarrationService simply finds no entry, falls
//  through to the device voice, and that passage never plays its recording
//  again. Nobody notices except a mother wondering why one card sounds
//  different from the rest.
//
//  So the builders are checked against the real manifest rather than trusted.
//  Two traps this pins down, both of which produce keys that LOOK right:
//
//    * `home.w4`  vs `home.w04`  — the keys came from filenames (week_04.json)
//      so the week is zero-padded.
//    * the second number is the day's index in its week (0-6), NOT the day of
//      pregnancy. Day 134 is index 0 of week 20.
// =============================================================================

import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:parentveda/services/narration_service.dart';

Map<String, dynamic> _manifest() {
  for (final p in [
    'build/audio/manifest_hi.json',
    'assets/narration/manifest_hi.json',
  ]) {
    final f = File(p);
    if (f.existsSync()) {
      return jsonDecode(f.readAsStringSync()) as Map<String, dynamic>;
    }
  }
  return const {};
}

/// The first day of pregnancy in [week], matching the seven-day files.
int _firstDayOf(int week) => (week - 1) * 7 + 1;

void main() {
  final manifest = _manifest();

  test('homeKey builds keys that exist, across the whole pregnancy', () {
    if (manifest.isEmpty) return; // generated output; a clean checkout has none

    final missing = <String>[];
    for (var week = 4; week <= 40; week++) {
      for (var i = 0; i < 7; i++) {
        final day = _firstDayOf(week) + i;
        // grow.expanded is authored for every day, so it is the honest probe.
        final key = NarrationService.homeKey(week, day, 'grow.expanded');
        if (!manifest.containsKey(key)) missing.add(key);
      }
    }
    expect(missing, isEmpty,
        reason: 'these keys would silently fall back to the device voice:\n'
            '${missing.take(8).join('\n')}');
  });

  test('homePrefix zero-pads the week', () {
    expect(NarrationService.homePrefix(4, 22), 'home.w04.0');
    expect(NarrationService.homePrefix(9, 60), 'home.w09.3');
    expect(NarrationService.homePrefix(20, 134), 'home.w20.0');
    expect(NarrationService.homePrefix(40, 280), 'home.w40.6');
  });

  test('the day index is derived, not assumed', () {
    // First and last day of week 20 — 134..140 in the file.
    expect(NarrationService.homeKey(20, 134, 'x'), 'home.w20.0.x');
    expect(NarrationService.homeKey(20, 140, 'x'), 'home.w20.6.x');
  });

  test('weekKey still matches weekContent entries', () {
    if (manifest.isEmpty) return;
    expect(manifest.containsKey(NarrationService.weekKey(20, 'babySnapshot.reveal')),
        isTrue);
    expect(
        manifest.containsKey(
            NarrationService.weekKey(33, 'babyDevelopment.whatImDoing')),
        isTrue);
  });
}

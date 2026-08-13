// =============================================================================
//  The voice must be reachable, not merely correct
// -----------------------------------------------------------------------------
//  NarrateButton was written, documented, covered by narration_keys_test.dart —
//  and had ZERO call sites. It compiled, the suite was green, 798 recordings sat
//  in assets/narration, and no user could play one. Audio only ever reached a
//  mother through autoPlay on a single screen; there was nothing to tap.
//
//  That is the exact failure CLAUDE.md's wiring gate names: "correct-but-
//  unreachable code is the failure this repo has actually hit." Test counts are
//  not evidence that a feature is reachable, so this checks reachability against
//  the source rather than trusting that someone remembered to use the widget.
//
//  Deliberately a source scan and not a widget test. A widget test would build
//  the button directly and pass whether or not any screen ever does — it would
//  re-create the very blind spot it was written to close.
// =============================================================================

import 'dart:io';

import 'package:flutter_test/flutter_test.dart';

/// Files that DEFINE the thing don't count as using it.
bool _isDefinition(String path) =>
    path.replaceAll(r'\', '/').contains('lib/widgets/narration/');

List<File> _dartFiles() => Directory('lib')
    .listSync(recursive: true)
    .whereType<File>()
    .where((f) => f.path.endsWith('.dart'))
    .toList();

void main() {
  test('NarrateButton is actually used by at least one screen', () {
    final users = <String>[];
    for (final f in _dartFiles()) {
      if (_isDefinition(f.path)) continue;
      if (f.readAsStringSync().contains('NarrateButton(')) {
        users.add(f.path);
      }
    }
    expect(users, isNotEmpty,
        reason: 'NarrateButton exists but nothing builds it, so no user can '
            'play a recording. It was in exactly this state once already.');
  });

  test('the narration service is initialised at startup', () {
    // Without init() the manifest is never loaded, hasAudio() is false for
    // everything, and every button silently falls back to the device voice —
    // which works, and therefore hides the fact that 66 MB of recordings are
    // doing nothing.
    final main = File('lib/main.dart').readAsStringSync();
    expect(main.contains('NarrationService.instance.init()'), isTrue,
        reason: 'NarrationService.init() is not called in main.dart');
  });

  test('every narration key built from a literal path is well formed', () {
    // `weekKey(week, path)` takes the JSON path — `babySnapshot.reveal` — not
    // the Dart field name. The model renames several (snapshot/babySnapshot,
    // mom/momJourney), so a key built from the Dart side looks right and
    // matches nothing. narration_keys_test.dart checks these against the
    // manifest when one is present; this catches the shape even without it.
    final call = RegExp(r"""weekKey\(\s*[^,]+,\s*'([^']*)'""");
    final offenders = <String>[];
    for (final f in _dartFiles()) {
      for (final m in call.allMatches(f.readAsStringSync())) {
        final path = m.group(1)!;
        if (!path.contains('.') || path.startsWith('.') || path.endsWith('.')) {
          offenders.add('${f.path}: "$path"');
        }
      }
    }
    expect(offenders, isEmpty,
        reason: 'a narration path must look like `block.field`:\n'
            '${offenders.join('\n')}');
  });
}
